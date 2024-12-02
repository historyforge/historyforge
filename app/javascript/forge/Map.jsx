import React, { useState, useRef } from 'react'
import { useSelector } from "react-redux";
import { useOpacity} from "./hooks/useOpacity";
import { useLayers } from "./hooks/useLayers";
import { useMarkers } from "./hooks/useMarkers";
import { useMapTargeting } from "./hooks/useMapTargeting";
import {MarkerClusterer} from "@googlemaps/markerclusterer";

const google = window.google
let boundsTimeout;
export const Map = () => {
  const props = useSelector(state => ({ ...state.layers, ...state.buildings, ...state.search }))
  const mapDivRef = useRef(null)
  const mapRef = useRef(null);
  const clusterMachine = useRef(null);

  const map = mapRef.current;
  const [bounds, setBounds] = useState(null);

    if (!mapRef.current && mapDivRef.current) {
      mapRef.current = new google.maps.Map(mapDivRef.current, mapOptions());
      mapRef.current.setCenter(props.center);

      clusterMachine.current = buildClusterMachine(mapRef.current);
      // We hide the forge controls when street view is on to give unimpeded street view.
      google.maps.event.addListener(mapRef.current.getStreetView(), 'visible_changed', () => {
        const streetViewOn = mapRef.current.getStreetView().getVisible();
        if (streetViewOn) {
          document.body.classList.add('streetview');
        } else {
          document.body.classList.remove('streetview');
        }
      });

      // We add markers only when the bounds have changed. Then we add only the markers visible
      // in the map bounds. Don't worry, when the map first loads, it fires bounds_changed. But
      // as you move the map, it also changes the bounds every step of the way. The timeout acts
      // as a trailing debounce to redo the markers only when you've stopped scrolling the map.
      google.maps.event.addListener(mapRef.current, "bounds_changed", () => {
        clearTimeout(boundsTimeout);
        boundsTimeout = setTimeout(() => {
          setBounds(mapRef.current.getBounds());
        }, 250);
      });
    }

  useLayers(mapRef.current);
  useOpacity(mapRef.current);
  useMarkers(mapRef.current, clusterMachine.current, bounds);
  useMapTargeting(mapRef.current, clusterMachine.current);

  return <div id="map-wrapper">
    <div id="map" ref={mapDivRef}/>
  </div>
}

function mapOptions() {
  return {
    zoom: 14,
    disableDefaultUI: true,
    gestureHandling: 'cooperative',
    zoomControl: true,
    mapTypeControl: true,
      mapTypeControlOptions: {
        style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
        position: google.maps.ControlPosition.TOP_RIGHT,
      },
    streetViewControl: true,
    styles: [{ featureType: 'poi', elementType: 'labels', stylers: [{ visibility: 'off' }] }]
  };
}

function buildClusterMachine(map) {
  return new MarkerClusterer({
    map,
    markers: [],
    renderer: { render: ({ count, position }) => {
        // create svg url with fill color
        const svg = window.btoa(`
  <svg fill="red" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240">
    <circle cx="120" cy="120" opacity=".8" r="70" />    
  </svg>`);
        const diameter = (count >= 100) ? 60 : count > 10 ? 50 : 40;
        // create marker using svg icon
        return new google.maps.Marker({
          position,
          icon: {
            url: `data:image/svg+xml;base64,${svg}`,
            scaledSize: new google.maps.Size(diameter, diameter),
          },
          label: {
            text: String(count),
            color: "rgba(255,255,255,0.9)",
            fontSize: "12px",
          },
          // adjust zIndex to be above other markers
          zIndex: Number(google.maps.Marker.MAX_ZINDEX) + count,
        });
      }}
  });
}
