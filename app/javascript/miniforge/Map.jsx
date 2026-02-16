import React, { useRef, useState, useEffect } from 'react'
import L from 'leaflet'
import loadWMS from '../forge/wms'
import { getMainIcon, generateMarkers, highlightMarker, unhighlightMarker } from '../forge/mapFunctions'
import { moveBuilding, highlight } from '../forge/actions'
import { useDispatch, useSelector } from "react-redux";

export const Map = () => {
  const {
    layeredAt,
    opacityAt,
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
  const toggle = (id) => dispatch({ type: 'LAYER_TOGGLE', id });

  const mapDivRef = useRef(null);
  const [map, setMap] = useState(null);
  const [markers, setMarkers] = useState(null);
  const [marker, setMarker] = useState(null);
  const [currentHighlight, setCurrentHighlight] = useState(null);
  const [lastLayeredAt, setLastLayeredAt] = useState(null);
  const [lastOpacityAt, setLastOpacityAt] = useState(null);
  const wmsLayerRef = useRef(null);

  useEffect(() => {
    if (!map && mapDivRef.current) {
      const leafletMap = L.map(mapDivRef.current, {
        zoom: 18,
        center: [center.lat, center.lng],
        zoomControl: true,
        scrollWheelZoom: false,
      });

      const streetLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        maxZoom: 19,
      }).addTo(leafletMap);

      const satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
        attribution: '&copy; Esri',
        maxZoom: 19,
      });

      L.control.layers(
        { 'Street': streetLayer, 'Satellite': satelliteLayer },
        null,
        { position: 'bottomleft' }
      ).addTo(leafletMap);

      setMap(leafletMap);
    }
  }, []);

  useEffect(() => {
    if (map && mapDivRef.current) {
      map.setView([center.lat, center.lng]);
    }
  }, [map, center]);

  useEffect(() => {
    if (map && mapDivRef.current) {
      if (!marker) {
        setMarker(addMainMarker(map, current, editable, (building) => dispatch(moveBuilding(building))))
        if (!layer) {
          const layerId = window.localStorage.getItem('miniforge-layer')
          if (layerId) {
            toggle(layerId)
          }
        } else {
          addLayer(map, layer, wmsLayerRef)
        }
      }
    }
  }, [map, marker, current, editable, layer]);

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
          onMouseOut(building) {
            dispatch(highlight(building.id));
          }
        }
        const nextMarkers = generateMarkers(buildings, handlers)
        if (nextMarkers) {
          addMarkers(map, Object.values(nextMarkers))
        }
        setMarkers(nextMarkers)
      } else {
        const wasHighlighted = parseInt(currentHighlight)
        const isHighlighted = parseInt(highlighted)
        const buildingId = building && parseInt(building.id)
        if (wasHighlighted && wasHighlighted !== isHighlighted) {
          unhighlightMarker(wasHighlighted, markers);
        }
        if (isHighlighted) {
          highlightMarker(isHighlighted, markers)
          setCurrentHighlight(isHighlighted);
        } else if (buildingId) {
          highlightMarker(buildingId, markers)
          setCurrentHighlight(buildingId);
        }
      }
    }
  }, [map, building, highlighted, currentHighlight, markers]);

  useEffect(() => {
    if (mapDivRef.current && map && layer) {
      if (layeredAt !== lastLayeredAt) {
        addLayer(map, layer, wmsLayerRef);
        setLastLayeredAt(layeredAt);
      }
    }
  }, [map, layer, layeredAt, lastLayeredAt]);

  useEffect(() => {
    if (mapDivRef.current && map && layer && opacity !== null) {
      if (opacityAt !== lastOpacityAt) {
        if (wmsLayerRef.current) {
          wmsLayerRef.current.setOpacity(parseInt(opacity) / 100);
        }
        setLastOpacityAt(opacityAt);
      }
    }
  }, [map, layer, opacity, opacityAt]);

  return <div id="map" ref={mapDivRef} />;
}

function addLayer(map, layer, wmsLayerRef) {
  if (wmsLayerRef.current) {
    map.removeLayer(wmsLayerRef.current);
    wmsLayerRef.current = null;
  }
  if (layer) {
    wmsLayerRef.current = loadWMS(map, layer);
    wmsLayerRef.current.addTo(map);
    window.localStorage.setItem("miniforge-layer", layer.id);
  }
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
