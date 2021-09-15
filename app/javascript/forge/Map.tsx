import React from 'react'
import {connect} from "react-redux";
import BaseMap from './BaseMap'
import loadWMS from "./wms";
import * as actions from './actions';

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
        let { map } = this.state
        if (!map) {
            map = new google.maps.Map(document.getElementById('map'), this.mapOptions)
            map.setCenter(this.props.center) //{lat: props.center[0], lng: window.Center[1]})
            this.setState({ map }, () => this.addLayers())
        }
    }

    addMarkers() {
        const clusterer = this.state.clusterer || new MarkerClusterer(this.state.map, [], {
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
        const { markers } = this
        if (markers)
            clusterer.addMarkers(markers)

        this.setState({ clusterer, markers })
    }

    handleMarkerClick(building) {
        this.props.select(building.id, this.props.params)
    }

    handleMarkerMouseOver(building, marker) {
        this.props.highlight(building.id)
        window.clearTimeout(this.infoWindowTimeout)
        if (this.infoWindow) {
            this.infoWindow.close()
        }
        this.setState({ currentMarker: marker })
        this.props.address(building.id)
    }

    infoWindowTimeout = null
    infoWindow = null

    handleMarkerMouseOut(building, marker) {
        this.props.highlight(building.id)
        this.infoWindowTimeout = window.setTimeout(() => {
            this.props.deAddress()
            this.infoWindow.close()
            this.setState({ currentMarker: null })
        }, 1000)
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

    processUpdates(prevProps) {
        if (this.propertyChanged(prevProps, 'addressedAt')) {
            const { bubble } = this.props
            const { currentMarker, map } = this.state
            if (bubble) {
                if (this.infoWindow) this.infoWindow.close()
                this.infoWindow = new google.maps.InfoWindow({
                    content: bubble.address
                })
                this.infoWindow.open({
                    anchor: currentMarker,
                    map
                })
            }
        }
    }
}

const mapStateToProps = state => {
    return {...state.layers, ...state.buildings, ...state.search}
}

const Component = connect(mapStateToProps, actions)(Map)

export default Component
