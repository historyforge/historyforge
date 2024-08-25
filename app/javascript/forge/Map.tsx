import React, { useState, useEffect, useRef } from 'react'
import { connect } from 'react-redux'
import loadWMS from './wms'
import * as actions from './actions'
import { propertyChanged, addOpacity, generateMarkers, highlightMarkers } from './MapComponent'
import { MarkerClusterer } from "@googlemaps/markerclusterer";

const google = window.google

const Map = (props: MapProps) => {
  const mapRef = useRef<HTMLDivElement>(null)
  const [map, setMap] = useState(null)
  const [markers, setMarkers] = useState(null)
  const [currentMarker, setCurrentMarker] = useState(null)
  const [clusterer, setClusterer] = useState(null)
  const [prevProps, setPrevProps] = useState(props)

  useEffect(() => {
    if (!map && mapRef.current) {
      const myMap = new google.maps.Map(mapRef.current, mapOptions())
      myMap.setCenter(props.center)
      setMap(myMap)
      google.maps.event.addListener(myMap.getStreetView(), 'visible_changed', () => {
        const streetViewOn = myMap.getStreetView().getVisible()
        if (streetViewOn) {
          document.body.classList.add('streetview')
        } else {
          document.body.classList.remove('streetview')
        }
      })
    }
  }, [map, mapRef]);

  const { layers, layeredAt, opacityAt, loadedAt } = props;

  useEffect(() => {
    if (map) {
      addLayers(map, layers)
    }
  }, [map, layeredAt]);

  useEffect(() => {
    if (map) {
      addOpacity(map, layers)
    }
  }, [map, opacityAt]);

  useEffect(() => {
    if (map) {
      if (propertyChanged(props, prevProps, 'loadedAt')) {
        const handlers = {
          onClick(building) {
            props.select(building.id, props.params)
          },
          onMouseOver(building, marker) {
            props.highlight(building.id)
            window.clearTimeout(infoWindowTimeout)
            if (infoWindow) {
              infoWindow.close()
            }
            setCurrentMarker(marker)
            props.address(building.id)
          },
          onMouseOut(building) {
            props.highlight(building.id)
            infoWindowTimeout = window.setTimeout(() => {
              props.deAddress()
              infoWindow.close()
              setCurrentMarker(null)
            }, 1000)
          }
        }
        const nextMarkers = generateMarkers(props.buildings, handlers)
        const nextClusterer = addClusters(map, clusterer, nextMarkers)
        setClusterer(nextClusterer)
        setMarkers(nextMarkers)
      }
      if (markers) {
        highlightMarkers(props, prevProps, markers)
      }

      if (propertyChanged(props, prevProps, 'focusOnPoints')) {
        if (props.focusOnPoints) {
          const bounds = new google.maps.LatLngBounds();
          props.focusOnPoints.forEach(point => bounds.extend(new google.maps.LatLng(point.lat, point.lon)));
          map.fitBounds(bounds);
          props.finishedFocusing();
        }
      }

      if (propertyChanged(props, prevProps, 'addressedAt')) {
        const { bubble } = props
        if (bubble) {
          if (infoWindow) infoWindow.close()
          infoWindow = new google.maps.InfoWindow({
            content: bubble.address
          })
          infoWindow.open({
            anchor: currentMarker,
            map
          })
        }
      }
    }
    setPrevProps(props)
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
  }
}

let infoWindowTimeout
let infoWindow

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

function addClusters(map, existingClusterer, markers) {
  const clusterer = existingClusterer || new MarkerClusterer({
    map,
    markers: [],
    renderer: { render: ({ count, position }, stats) => {
      const color = "red";
      // create svg url with fill color
      const svg = window.btoa(`
  <svg fill="${color}" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240">
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

  clusterer.clearMarkers();

  if (markers) {
    clusterer.addMarkers(Object.values(markers));
  }

  return clusterer;
}

const mapStateToProps = state => {
  return { ...state.layers, ...state.buildings, ...state.search }
}

const Component = connect(mapStateToProps, actions)(Map)

export default Component
