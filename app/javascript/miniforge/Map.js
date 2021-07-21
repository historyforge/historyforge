import React from 'react'
import {connect} from "react-redux";
import loadWMS from "../forge/wms";

class Map extends React.PureComponent {
    state = { map: null }
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

    componentDidUpdate(prevProps, prevState, snapshot) {
        if ((!prevProps.layeredAt && this.props.layeredAt) || (prevProps.layeredAt !== this.props.layeredAt)) {
            this.addLayers()
        }
        if ((!prevProps.opacityAt && this.props.opacityAt) || (prevProps.opacityAt !== this.props.opacityAt)) {
            this.doOpacity()
        }
        if (prevProps.highlighted && prevProps.highlighted !== this.props.highlighted) {
            this.unhighlightMarker(prevProps.highlighted)
        }
        if (this.props.highlighted) {
            this.highlightMarker(this.props.highlighted)
            // if (this.props.building) {
            //     const buildingId = parseInt(this.props.building.id)
            //     if (buildingId !== this.props.highlighted)
            //         this.unhighlightMarker(buildingId)
            // }
        } else if (this.props.building) {
            this.highlightMarker(parseInt(this.props.building.id))
        }
    }

    highlightMarker(id) {
        const marker = this.state.markers.find(item => item.buildingId === id)
        marker.setIcon(this.iconHover)
        marker.setZIndex(100)
    }

    unhighlightMarker(id) {
        const marker = this.state.markers.find(item => item.buildingId === id)
        marker.setIcon(this.iconStatic)
        marker.setZIndex(10)
    }

    iconCurrent = {
        path: google.maps.SymbolPath.CIRCLE,
        fillColor: 'green',
        fillOpacity: .9,
        scale: 10,
        strokeColor: '#333',
        strokeWeight: 1,
    }

    iconHover = {
        path: google.maps.SymbolPath.CIRCLE,
        fillColor: 'blue',
        fillOpacity: 0.9,
        scale: 6,
        strokeColor: '#333',
        strokeWeight: 1
    }

    iconStatic = {
        path: google.maps.SymbolPath.CIRCLE,
        fillColor: 'red',
        fillOpacity: 0.9,
        scale: 6,
        strokeColor: '#333',
        strokeWeight: 1
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
        const { markers } = this
        this.setState({ markers })
    }

    get markers() {
        const { map } = this.state
        return this.props.buildings && this.props.buildings.map(b => {
            const building = b.data.attributes
            const marker = new google.maps.Marker({
                position: new google.maps.LatLng(building.latitude, building.longitude),
                icon: this.iconStatic,
                zIndex: 10,
                map
            })
            marker.buildingId = building.id
            google.maps.event.addListener(marker, 'click', () => {
                this.props.highlight(building.id)
            })
            google.maps.event.addListener(marker, 'mouseover', () => {
                this.props.highlight(building.id)
            })
            google.maps.event.addListener(marker, 'mouseout', () => {
                this.props.highlight(building.id)
            })
            return marker
        })
    }

    addLayers() {
        const { map } = this.state
        const layer = this.props.layer || this.props.layers[0]
        const currentLayers = map.overlayMapTypes.getArray()
        if (currentLayers.length) {
            if (currentLayers[0] === layer.name) return
            map.overlayMapTypes.removeAt(0)
        }
        loadWMS(map, layer, layer.name)
        this.doOpacity()
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
