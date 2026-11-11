import React, { useRef, useState, useEffect } from 'react'
import L from 'leaflet'
import { createStreetLayer } from '../forge/streetLayer'
import { createSatelliteLayer } from '../forge/satelliteLayer'
import loadWMS from '../forge/wms'
import { getMainIcon, generateMarkers } from '../forge/mapFunctions'
import { moveBuilding, highlight } from '../forge/actions'
import { addFullscreenControl } from './fullscreenControl'
import { useDispatch, useSelector } from "react-redux";

const historicalLayerKey = 'miniforge-layer'

export const Map = () => {
  const {
    center,
    layer,
    opacity,
    current,
    building,
    highlighted,
    editable,
    buildings,
  } = useSelector(state => ({ ...state.layers, ...state.buildings, ...state.search }));
  const dispatch = useDispatch();

  const mapDivRef = useRef(null);
  const [map, setMap] = useState(null);
  const [markers, setMarkers] = useState(null);
  const [marker, setMarker] = useState(null);
  const [currentHighlight, setCurrentHighlight] = useState(null);
  const wmsLayerRef = useRef(null);

  useEffect(() => {
    if (!map && mapDivRef.current) {
      const leafletMap = L.map(mapDivRef.current, {
        zoom: 18,
        center: [center.lat, center.lng],
        zoomControl: true,
        scrollWheelZoom: false,
      });

      const streetLayer = createStreetLayer().addTo(leafletMap)

      const satelliteLayer = createSatelliteLayer();

      L.control.layers(
        { 'Street': streetLayer, 'Satellite': satelliteLayer },
        null,
        { position: 'bottomleft' }
      ).addTo(leafletMap);

      addFullscreenControl(leafletMap, mapDivRef.current)

      const savedLayerId = window.localStorage.getItem(historicalLayerKey)
      if (savedLayerId) dispatch({ type: 'LAYER_TOGGLE', id: savedLayerId })

      setMap(leafletMap);

      return () => {
        leafletMap.remove();
        wmsLayerRef.current = null;
      };
    }
  }, []);

  useEffect(() => {
    if (map && mapDivRef.current) {
      map.setView([center.lat, center.lng]);
    }
  }, [map, center]);

  useEffect(() => {
    if (map && !marker) {
      setMarker(addMainMarker(map, current, editable, (building) => dispatch(moveBuilding(building))))
    }
  }, [map, marker, current, editable]);

  useEffect(() => {
    if (map && mapDivRef.current) {
      if (!markers) {
        const handlers = {
          onClick(building) {
            dispatch(highlight(building.id));
          },
          onMouseOver(building) {
            dispatch(highlight(building.id));
          },
          onMouseOut() {
            dispatch(highlight(null));
          }
        }
        const nextMarkers = generateMarkers(buildings, handlers)
        if (nextMarkers) {
          addMarkers(map, Object.values(nextMarkers))
        }
        setMarkers(nextMarkers)
      } else {
        const nextHighlight = highlighted || (building && building.id) || null
        if (currentHighlight !== nextHighlight) {
          // Reordering SVG paths under the pointer can trigger hover loops
          // when nearby buildings overlap. Only change their color here.
          if (markers[currentHighlight]) markers[currentHighlight].setStyle({ fillColor: 'red' })
          if (markers[nextHighlight]) markers[nextHighlight].setStyle({ fillColor: 'blue' })
          setCurrentHighlight(nextHighlight)
        }
      }
    }
  }, [map, building, highlighted, currentHighlight, markers]);

  useEffect(() => {
    if (!map) return

    wmsLayerRef.current?.remove()
    wmsLayerRef.current = null
    if (layer) {
      wmsLayerRef.current = loadWMS(map, layer).addTo(map)
      window.localStorage.setItem(historicalLayerKey, layer.id)
    } else {
      window.localStorage.removeItem(historicalLayerKey)
    }
  }, [map, layer]);

  useEffect(() => {
    wmsLayerRef.current?.setOpacity(Number(opacity ?? 100) / 100)
  }, [map, layer, opacity]);

  return <div id="map" ref={mapDivRef} />;
}

function addMarkers(map, markers) {
  markers.forEach(marker => marker.addTo(map))
}

function addMainMarker(map, current, editable, move) {
  const marker = L.marker(
    [current.object.lat, current.object.lon],
    { icon: getMainIcon(), zIndexOffset: 12, draggable: editable }
  ).addTo(map);

  if (editable) {
    marker.on('dragend', () => {
      const latlng = marker.getLatLng();
      move({ lat: latlng.lat, lon: latlng.lng });
    });
  }
  return marker;
}
