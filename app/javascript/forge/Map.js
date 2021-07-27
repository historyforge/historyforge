import React from 'react'
import {connect} from "react-redux";
import BaseMap from './BaseMap'

class Map extends BaseMap {
    mapOptions = {
        zoom: 14,
        disableDefaultUI: true,
        gestureHandling: 'cooperative',
        zoomControl: true,
        mapTypeControl: true,
        mapTypeControlOptions: {
            mapTypeIds: [ google.maps.MapTypeId.ROADMAP, google.maps.MapTypeId.SATELLITE ],
            style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
            position: google.maps.ControlPosition.BOTTOM_LEFT,
        },
        streetViewControl: true,
        styles: [{ featureType: 'poi', elementType: 'labels', stylers: [{ visibility: 'off' }]}]
    }

    render() {
        return <div id="map-wrapper"><div id="map" /></div>
    }

    componentDidMount() {
        this.props.load(this.props.params)
        let { map } = this.state
        if (!map) {
            map = new google.maps.Map(document.getElementById('map'), this.mapOptions)
            map.setCenter({lat: window.mapCenter[0], lng: window.mapCenter[1]})
            this.setState({ map }, () => this.addLayers())
        }
    }

    addMarkers() {
        const clusterer = this.state.clusterer || new MarkerClusterer(this.state.map, [], {
            imagePath: 'https://cdn.rawgit.com/googlemaps/js-marker-clusterer/gh-pages/images/m',
            minimumClusterSize: 10,
            maxZoom: 16,
        })

        clusterer.clearMarkers()
        const { markers } = this
        if (markers)
            clusterer.addMarkers(markers)

        this.setState({ clusterer, markers })
    }

    handleMarkerClick(building) {
        this.props.select(building.id, this.props.params)
    }

    handleMarkerMouseOver(building) {
        this.props.highlight(building.id)
    }

    handleMarkerMouseOut(building) {
        this.props.highlight(building.id)
    }

    addLayers() {
        const selectedLayers = this.props.layers.filter(layer => layer.selected)

        const { map } = this.state
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

    doOpacity() {
        const { map } = this.state
        const currentLayers = map.overlayMapTypes.getArray()
        currentLayers.forEach(layer => {
            const opacity = this.props.layers.find(l => l.id === layer.name).opacity
            if (typeof(opacity) === 'number')
                layer.setOpacity(opacity / 100)
            else
                layer.setOpacity(1)
        })
    }
}

const mapStateToProps = state => {
    return {...state.layers, ...state.buildings, ...state.search}
}

const actions = {
    load: (params) => ({ type: 'BUILDING_LOAD', params }),
    highlight: (id) => ({ type: 'BUILDING_HIGHLIGHT', id }),
    select: (id, params) => ({ type: 'BUILDING_SELECT', id, params })
}

const Component = connect(mapStateToProps, actions)(Map)

export default Component
