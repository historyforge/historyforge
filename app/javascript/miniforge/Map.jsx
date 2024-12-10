import React, { useRef, useState, useEffect } from 'react'
import loadWMS from '../forge/wms'
import { getMainIcon, generateMarkers, highlightMarker, unhighlightMarker } from '../forge/mapFunctions'
import { moveBuilding, highlight } from '../forge/actions'
import {useDispatch, useSelector} from "react-redux";

const google = window.google

const getMapOptions = () => ({
  zoom: 18,
  disableDefaultUI: true,
  gestureHandling: 'cooperative',
  zoomControl: true,
  mapTypeControl: true,
  mapTypeControlOptions: {
    mapTypeIds: [google.maps.MapTypeId.ROADMAP, google.maps.MapTypeId.SATELLITE],
    style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
    position: google.maps.ControlPosition.BOTTOM_LEFT
  },
  streetViewControl: true,
  fullscreenControl: true,
  styles: [{ featureType: 'poi', elementType: 'labels', stylers: [{ visibility: 'off' }] }]
});


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

  const mapRef = useRef(null);
  const [map, setMap] = useState(null);
  const [markers, setMarkers] = useState(null);
  const [marker, setMarker] = useState(null);
  const [currentHighlight, setCurrentHighlight] = useState(null);
  const [lastLayeredAt, setLastLayeredAt] = useState(null);
  const [lastOpacityAt, setLastOpacityAt] = useState(null);

  useEffect(() => {
    if (!map && mapRef.current) {
      setMap(new google.maps.Map(mapRef.current, getMapOptions()));
    }
  }, [map]);

  useEffect(() => {
    if (map && mapRef.current) {
      map.setCenter(center)
    }
  }, [map, center]);

  useEffect(() => {
    if (map && mapRef.current) {
      if (!marker) {
        setMarker(addMainMarker(map, current, editable, (building) => dispatch(moveBuilding(building))))
        if (!layer) {
          const layerId = window.localStorage.getItem('miniforge-layer')
          if (layerId) {
            toggle(layerId)
          }
        } else {
          addLayer(map, layer)
        }
      }
    }
  }, [map, marker, current, editable, layer]);

  useEffect(() => {
    if (map && mapRef.current) {
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
        addMarkers(map, Object.values(nextMarkers))
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
    if (mapRef.current && map && layer) {
      if (layeredAt !== lastLayeredAt) {
        addLayer(map, layer);
        setLastLayeredAt(layeredAt);
      }
    }
  }, [map, layer, layeredAt, lastLayeredAt]);

  useEffect(() => {
    if (mapRef.current && map && layer && opacity !== null) {
      if (opacityAt !== lastOpacityAt) {
        addOpacity(map, opacity);
        setLastOpacityAt(opacityAt);
      }
    }
  }, [map, layer, opacity, opacityAt]);

  return <div id="map" ref={mapRef} />;
}

function addLayer(map, layer) {
  const currentLayers = map.overlayMapTypes.getArray();
  currentLayers.forEach((_, index) => {
    map.overlayMapTypes.removeAt(index);
  })
  if (layer) {
    loadWMS(map, layer, "top");
    window.localStorage.setItem("miniforge-layer", layer.id);
  }
}

export function addOpacity(map, opacity) {
  const currentLayers = map.overlayMapTypes.getArray()
  currentLayers[0].setOpacity(parseInt(opacity) / 100)
}

function addMarkers(map, markers) {
  markers.forEach(marker => marker.setMap(map))
}

function addMainMarker(map, current, editable, move) {
  const marker = new google.maps.Marker({
    position: new google.maps.LatLng(current.object.lat, current.object.lon),
    icon: getMainIcon(),
    zIndex: 12,
    map,
    draggable: editable
  })
  if (editable) {
    google.maps.event.addListener(marker, 'dragend', (event) => {
      const point = event.latLng
      move({ lat: point.lat(), lon: point.lng() })
    })
  }
  return marker
}
