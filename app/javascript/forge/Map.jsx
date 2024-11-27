import React, { useState, useEffect, useRef } from 'react'
import loadWMS from './wms'
import * as actions from './actions'
import {
  addOpacity,
  generateMarkers,
  unhighlightMarker,
  highlightMarker
} from './MapComponent'
import { MarkerClusterer } from "@googlemaps/markerclusterer";
import { useDispatch, useSelector } from "react-redux";

const google = window.google
let boundsTimeout;
export const Map = () => {
  const dispatch = useDispatch();
  const props = useSelector(state => ({ ...state.layers, ...state.buildings, ...state.search }))
  const mapRef = useRef(null)
  const infoWindowTimeout = useRef(null);
  const infoWindow = useRef(null);

  const [map, setMap] = useState(null);
  const [markers, setMarkers] = useState(null);
  const [currentMarker, setCurrentMarker] = useState(null);
  const [clusters, setClusters] = useState(null);
  const [bounds, setBounds] = useState(null);
  const [prevLoadedAt, setPrevLoadedAt] = useState(null);
  const [prevAddressedAt, setPrevAddressedAt] = useState(null);
  const [prevFocusOnPoints, setPrevFocusOnPoints] = useState(null);
  const [prevHighlighted, setPrevHighlighted] = useState(null);

  useEffect(() => {
    if (!map && mapRef.current) {
      const myMap = new google.maps.Map(mapRef.current, mapOptions());
      myMap.setCenter(props.center);
      setMap(myMap);
      google.maps.event.addListener(myMap.getStreetView(), 'visible_changed', () => {
        const streetViewOn = myMap.getStreetView().getVisible();
        if (streetViewOn) {
          document.body.classList.add('streetview');
        } else {
          document.body.classList.remove('streetview');
        }
      });
      google.maps.event.addListener(myMap, "bounds_changed", () => {
        clearTimeout(boundsTimeout);
        boundsTimeout = setTimeout(() => {
          setBounds(myMap.getBounds());
        }, 250);
      });
    }
  }, [map, mapRef]);

  const { layers, layeredAt, opacityAt, loadedAt, addressedAt, highlighted, focusOnPoints } = props;

  const addMarkers = () => {
    if (!bounds || !markers) { return; }
    console.log("Adding markers");
    const desiredMarkers = Object.values(markers).filter(marker => bounds.contains(marker.position));
    const nextClusters = addClusters(map, clusters, desiredMarkers);
    setClusters(nextClusters);
  }

  useEffect(() => {
    if (!map) { return; }
    addLayers(map, layers);
  }, [map, layeredAt]);

  useEffect(() => {
    if (!map) { return; }
    addOpacity(map, layers);
  }, [map, opacityAt]);

  useEffect(() => {
    if (!map) { return; }

    if (markers) {
      const isHighlighted = parseInt(highlighted);
      const buildingId = props.building && parseInt(props.building.id);
      if (prevHighlighted && prevHighlighted !== isHighlighted) {
        if (prevHighlighted) { setPrevHighlighted(isHighlighted); }
        unhighlightMarker(prevHighlighted, markers);
      }
      if (isHighlighted) {
        highlightMarker(isHighlighted, markers);
      } else if (buildingId) {
        highlightMarker(buildingId, markers);
      }
   }

  }, [map, highlighted, prevHighlighted, markers]);

  useEffect(() => {
    if (!map || prevLoadedAt === loadedAt) { return; }
    const handlers = {
      onClick(building) {
        dispatch(actions.select(building.id, props.params));
      },
      onMouseOver(building, marker) {
        dispatch(actions.highlight(building.id));
        window.clearTimeout(infoWindowTimeout.current);
        if (infoWindow.current) {
          infoWindow.current.close();
        }
        setCurrentMarker(marker);
        dispatch(actions.address(building.id));
      },
      onMouseOut(building) {
        dispatch(actions.highlight(building.id));
        infoWindowTimeout.current = window.setTimeout(() => {
          dispatch(actions.deAddress());
          infoWindow.current.close();
          setCurrentMarker(null);
        }, 1000);
      }
    }
    const nextMarkers = generateMarkers(props.buildings, handlers);
    setMarkers(nextMarkers);
    setPrevLoadedAt(loadedAt);
  }, [map, loadedAt, prevLoadedAt]);

  useEffect(() => {
    if (map && markers && bounds) {
      addMarkers();
    }
  }, [map, markers, bounds]);

  useEffect(() => {
    if (!map) {
      return;
    }

    if (focusOnPoints && prevFocusOnPoints !== focusOnPoints) {
      const bounds = new google.maps.LatLngBounds();
      focusOnPoints.forEach(point => bounds.extend(new google.maps.LatLng(point.lat, point.lon)));
      map.fitBounds(bounds);
      dispatch(actions.finishedFocusing());
      setPrevFocusOnPoints(focusOnPoints);
    }
  }, [map, focusOnPoints, focusOnPoints]);

  useEffect(() => {
    if (!map) {
      return;
    }

    if (prevAddressedAt !== addressedAt) {
      setPrevAddressedAt(addressedAt);
      const { bubble } = props;
      if (bubble) {
        if (infoWindow.current) infoWindow.current.close();
        infoWindow.current = new google.maps.InfoWindow({
          content: bubble.address
        })
        infoWindow.current.open({
          anchor: currentMarker,
          map
        });
      }
    }
  });

  return <div id="map-wrapper">
    <div id="map" ref={mapRef}/>
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

function addLayers(map, layers) {
  const selectedLayers = layers.filter(layer => layer.selected).sort((a, b) => a.year_depicted > b.year_depicted ? 1 : -1);
  const selectedLayerIds = selectedLayers.map(layer => layer.id);
  const currentLayers = map.overlayMapTypes.getArray();
  const currentLayerIds = currentLayers.map(layer => layer.name); // Name is actually an ID here...
  currentLayerIds.forEach((name, index) => {
    if (selectedLayerIds.indexOf(name) === -1) {
      map.overlayMapTypes.removeAt(index);
    }
  });
  selectedLayerIds.forEach((id, selectedIndex) => {
    if (currentLayerIds.indexOf(id) === -1) {
      loadWMS(map, selectedLayers[selectedIndex], selectedIndex);
    }
  });
}

function addClusters(map, existingClusters, markers) {
  const clusters = existingClusters || new MarkerClusterer({
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

  clusters.clearMarkers();

  if (markers) {
    clusters.addMarkers(markers);
  }

  return clusters;
}
