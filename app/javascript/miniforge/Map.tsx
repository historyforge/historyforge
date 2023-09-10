import React, { useRef, useState, useEffect } from 'react'
import { connect } from 'react-redux'
import loadWMS from '../forge/wms'
import { getMainIcon, generateMarkers, highlightMarkers, propertyChanged } from '../forge/MapComponent'
import { moveBuilding, highlight } from '../forge/actions'

const google = window.google

function mapOptions() {
  return {
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
        if (!props.layer) {
          const layerId = window.localStorage.getItem('miniforge-layer')
          if (layerId) {
            props.toggle(layerId)
          }
        } else {
          addLayer(map, props.layer)
        }
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
        addLayer(map, props.layer)
      }
      if (propertyChanged(props, prevProps, 'opacityAt')) {
        addOpacity(map, props.opacity)
      }
    }
    setPrevProps(props)
  })

  return <div id="map" ref={mapRef} />
}

function addLayer(map, layer) {
  const currentLayers = map.overlayMapTypes.getArray()
  if (currentLayers.length) {
    map.overlayMapTypes.removeAt(0)
  }
  if (layer) {
    loadWMS(map, layer, layer.name)
    window.localStorage.setItem('miniforge-layer', layer.id)
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

const mapStateToProps = state => {
  return { ...state.layers, ...state.buildings, ...state.search }
}

const actions = {
  toggle: (id) => ({ type: 'LAYER_TOGGLE', id }),
  move: moveBuilding,
  highlight
}

const Component = connect(mapStateToProps, actions)(Map)

export default Component
