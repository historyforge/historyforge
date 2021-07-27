import React from 'react'
import {connect} from "react-redux";
import loadWMS from "../forge/wms";
import BaseMap from '../forge/BaseMap'
class Map extends BaseMap {
    mapOptions = {
        zoom: 18,
        disableDefaultUI: true,
        gestureHandling: 'cooperative',
        zoomControl: true,
        mapTypeControl: false,
        streetViewControl: true,
        fullscreenControl: true,
        styles: [{ featureType: 'poi', elementType: 'labels', stylers: [{ visibility: 'off' }]}]
    }

    iconCurrent = Object.assign({}, this.iconBase, {
        fillColor: 'green',
        scale: 10,
    })

    render() {
        return <div id="map" />
    }

    componentDidMount() {
        let { map } = this.state
        if (!map) {
            map = new google.maps.Map(document.getElementById('map'), this.mapOptions)
            map.setCenter({lat: window.mapCenter[0], lng: window.mapCenter[1]})
            this.setState({ map }, () => {
                this.addLayers()
                this.addMarkers()
                this.addCurrent()
            })
        }
    }

    addCurrent() {
        const { current, editable } = this.props
        const { map } = this.state
        const marker = new google.maps.Marker({
            position: new google.maps.LatLng(current.lat, current.lon),
            icon: this.iconCurrent,
            zIndex: 12,
            map,
            draggable: editable
        })
        if (editable)
            google.maps.event.addListener(marker, 'dragend', (event) => {
                const point = event.latLng
                this.props.move({ lat: point.lat(), lon: point.lng() })
            })
        this.setState({ marker })
    }

    addMarkers() {
        const {markers} = this
        markers.forEach((marker) => {
            marker.setMap(this.state.map)
        })
        this.setState({ markers })
    }

    handleMarkerClick(building) {
        this.props.highlight(building.id)
    }

    handleMarkerMouseOver(building) {
        this.props.highlight(building.id)
    }

    handleMarkerMouseOut(building) {
        this.props.highlight(building.id)
    }

    addLayers() {
        const { map } = this.state
        const layer = this.props.layer || this.props.layers[0]
        const currentLayers = map.overlayMapTypes.getArray()
        if (currentLayers.length) {
            if (currentLayers[0] === layer.name) return
            map.overlayMapTypes.removeAt(0)
        }
        if (layer) {
            loadWMS(map, layer, layer.name)
            this.doOpacity()
        }
    }

    doOpacity() {
        const { map } = this.state
        const opacity = this.props.opacity || 100
        const currentLayers = map.overlayMapTypes.getArray()
        currentLayers.forEach(layer => {
            layer.setOpacity(opacity / 100)
        })
    }
}

const mapStateToProps = state => {
    return {...state.layers, ...state.buildings, ...state.search}
}

const actions = {
    move: (point) => ({ type: 'BUILDING_MOVE', point }),
    highlight: (id) => ({ type: 'BUILDING_HIGHLIGHT', id }),
}

const Component = connect(mapStateToProps, actions)(Map)

export default Component
