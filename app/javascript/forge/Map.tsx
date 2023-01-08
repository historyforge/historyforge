import React, { useState, useEffect, useRef } from 'react'
import { connect } from 'react-redux'
import loadWMS from './wms'
import * as actions from './actions'
import { propertyChanged, addOpacity, generateMarkers, highlightMarkers } from './MapComponent'

const google = window.google
// @ts-ignore
const MarkerClusterer = window.MarkerClusterer

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
      mapTypeIds: [google.maps.MapTypeId.ROADMAP, google.maps.MapTypeId.SATELLITE],
      style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
      position: google.maps.ControlPosition.BOTTOM_LEFT
    },
    streetViewControl: true,
    styles: [{ featureType: 'poi', elementType: 'labels', stylers: [{ visibility: 'off' }] }]
  }
}

let infoWindowTimeout
let infoWindow

function addLayers(map, layers) {
  const selectedLayers = layers.filter(layer => layer.selected)
  const currentLayers = map.overlayMapTypes.getArray()
  const selectedLayerNames = selectedLayers.map(layer => layer.name)
  const currentLayerNames = currentLayers.map(layer => layer.name)
  currentLayerNames.forEach((name, index) => {
    if (selectedLayerNames.indexOf(name) === -1) {
      map.overlayMapTypes.removeAt(index)
    }
  })
  selectedLayerNames.forEach((name, index) => {
    if (currentLayerNames.indexOf(name) === -1) {
      loadWMS(map, selectedLayers[index], name)
    }
  })
}

function addClusters(map, existingClusterer, markers) {
  const clusterer = existingClusterer || new MarkerClusterer(map, [], {
    minimumClusterSize: 10,
    maxZoom: 20,
    styles: [
      {
        textColor: 'white',
        url: '/markerclusterer/m1.png',
        width: 53,
        height: 52
      }, {
        textColor: 'white',
        url: '/markerclusterer/m2.png',
        width: 56,
        height: 55
      }, {
        textColor: 'white',
        url: '/markerclusterer/m3.png',
        width: 66,
        height: 65
      }
    ]
  })

  clusterer.clearMarkers()

  if (markers) { clusterer.addMarkers(Object.values(markers)) }

  return clusterer
}

const mapStateToProps = state => {
  return { ...state.layers, ...state.buildings, ...state.search }
}

const Component = connect(mapStateToProps, actions)(Map)

export default Component
