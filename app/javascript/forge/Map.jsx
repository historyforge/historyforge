import React, { useRef, useEffect } from 'react'
import { useSelector } from "react-redux";
import { useLayers } from "./hooks/useLayers";
import { useMarkers } from "./hooks/useMarkers";
import { useMapTargeting } from "./hooks/useMapTargeting";
import L from 'leaflet';
import 'leaflet.markercluster';
import { createStreetLayer } from './streetLayer'
import { createSatelliteLayer } from './satelliteLayer'

export const Map = () => {
  const props = useSelector(state => ({ ...state.layers, ...state.buildings, ...state.search }))
  const mapDivRef = useRef(null)
  const mapRef = useRef(null);
  const clusterMachine = useRef(null);

  useEffect(() => {
    if (!mapRef.current && mapDivRef.current) {
      mapRef.current = L.map(mapDivRef.current, {
        zoom: 14,
        center: [props.center.lat, props.center.lng],
        maxZoom: 22,
        zoomControl: false,
        scrollWheelZoom: false,
      });

      L.control.zoom({ position: 'bottomright' }).addTo(mapRef.current);

      const street = createStreetLayer().addTo(mapRef.current)

      const satellite = createSatelliteLayer();

      L.control.layers(
        { 'Street': street, 'Satellite': satellite },
        null,
        { position: 'topright' }
      ).addTo(mapRef.current);

      clusterMachine.current = buildClusterGroup();
      clusterMachine.current.addTo(mapRef.current);

      return () => {
        mapRef.current.remove();
        mapRef.current = null;
        clusterMachine.current = null;
      };
    }
  }, []);

  useLayers(mapRef.current);
  useMarkers(mapRef.current, clusterMachine.current);
  useMapTargeting(mapRef.current, clusterMachine.current);

  return <div id="map-wrapper">
    <div id="map" ref={mapDivRef} />
  </div>
}

function buildClusterGroup() {
  return L.markerClusterGroup({
    chunkedLoading: true,
    maxClusterRadius: 50,
    iconCreateFunction: (cluster) => {
      const count = cluster.getChildCount();
      const diameter = count >= 100 ? 60 : count > 10 ? 50 : 40;
      return L.divIcon({
        html: `<div style="
          width:${diameter}px;
          height:${diameter}px;
          line-height:${diameter}px;
          text-align:center;
          border-radius:50%;
          background:rgba(255,0,0,0.8);
          color:rgba(255,255,255,0.9);
          font-size:12px;
        ">${count}</div>`,
        className: '',
        iconSize: [diameter, diameter],
      });
    }
  });
}
