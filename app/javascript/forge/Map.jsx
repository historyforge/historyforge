import React, { useRef, useEffect } from 'react'
import { useSelector } from "react-redux";
import { useLayers } from "./hooks/useLayers";
import { useMarkers } from "./hooks/useMarkers";
import { useMapTargeting } from "./hooks/useMapTargeting";
import L from 'leaflet';
import 'leaflet.markercluster';

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
        zoomControl: false,
        scrollWheelZoom: false,
      });

      L.control.zoom({ position: 'bottomright' }).addTo(mapRef.current);

      const street = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        maxZoom: 19,
      }).addTo(mapRef.current);

      const satellite = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
        attribution: '&copy; Esri',
        maxZoom: 19,
      });

      L.control.layers(
        { 'Street': street, 'Satellite': satellite },
        null,
        { position: 'topright' }
      ).addTo(mapRef.current);

      clusterMachine.current = buildClusterGroup();
      clusterMachine.current.addTo(mapRef.current);
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
