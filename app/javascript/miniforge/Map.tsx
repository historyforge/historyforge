import React, { useRef, useState, useEffect } from 'react'
import { connect } from 'react-redux'
import loadWMS from '../forge/wms'
import { getMainIcon, addOpacity, generateMarkers, highlightMarkers, propertyChanged } from '../forge/MapComponent'
import { moveBuilding, highlight } from '../forge/actions'

const google = window.google

function mapOptions() {
  return {
    zoom: 18,
    disableDefaultUI: true,
    gestureHandling: 'cooperative',
    zoomControl: true,
    mapTypeControl: false,
    streetViewControl: true,
    fullscreenControl: true,
    styles: [{ featureType: 'poi', elementType: 'labels', stylers: [{ visibility: 'off' }] }]
  }
}

const Map = props => {
  const mapRef = useRef<HTMLDivElement>(null)
  const [map, setMap] = useState(null)
  const [markers, setMarkers] = useState(null)
  const [marker, setMarker] = useState(null)
  const [prevProps, setPrevProps] = useState(props)

  useEffect(() => {
    if (!map && mapRef.current) {
      const myMap = new google.maps.Map(mapRef.current, mapOptions())
      myMap.setCenter(props.center)
      setMap(myMap)
    }
    if (map) {
      if (!marker) {
        setMarker(addMainMarker(map, props.current, props.editable, props.move))
        addLayer(map, props.layer || props.layers[0])
      }
      if (!markers) {
        const handlers = {
          onClick(building) {
            props.highlight(building.id)
          },
          onMouseOver(building) {
            props.highlight(building.id)
          },
          onMouseOut(building) {
            props.highlight(building.id)
          }
        }
        const nextMarkers = generateMarkers(props.buildings, handlers)
        addMarkers(map, Object.values(nextMarkers))
        setMarkers(nextMarkers)
      } else {
        highlightMarkers(props, prevProps, markers)
      }
      if (propertyChanged(props, prevProps, 'layeredAt')) {
        addLayer(map, props.layer || props.layers[0])
      }
      if (propertyChanged(props, prevProps, 'opacityAt')) {
        addOpacity(map, [props.layer || props.layers[0]])
      }
    }
    setPrevProps(props)
  })

  return <div id="map" ref={mapRef} />
}

function addLayer(map, layer) {
  const currentLayers = map.overlayMapTypes.getArray()
  if (currentLayers.length) {
    if (currentLayers[0] === layer.name) {
      return
    }
    map.overlayMapTypes.removeAt(0)
  }
  if (layer) {
    loadWMS(map, layer, layer.name)
  }
}

function addMarkers(map, markers) {
  markers.forEach(marker => marker.setMap(map))
}

function addMainMarker(map, current, editable, move) {
  const marker = new google.maps.Marker({
    position: new google.maps.LatLng(current.lat, current.lon),
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

const mapStateToProps = state => {
  return { ...state.layers, ...state.buildings, ...state.search }
}

const actions = {
  move: moveBuilding,
  highlight
}

const Component = connect(mapStateToProps, actions)(Map)

export default Component
