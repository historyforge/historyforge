import React from 'react'
import loadWMS from "./wms";

class BaseMap extends React.PureComponent {
    state = { map: null }
    mapOptions = {}

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

    render() {}

    componentDidMount() {}

    componentDidUpdate(prevProps, prevState, snapshot) {
        if ((!prevProps.layeredAt && this.props.layeredAt) || (prevProps.layeredAt !== this.props.layeredAt)) {
            this.addLayers()
        }
        if ((!prevProps.opacityAt && this.props.opacityAt) || (prevProps.opacityAt !== this.props.opacityAt)) {
            this.doOpacity()
        }
        if ((!prevProps.loadedAt && this.props.loadedAt) || (prevProps.loadedAt !== this.props.loadedAt)) {
            this.addMarkers()
        }
        if (prevProps.highlighted && prevProps.highlighted !== this.props.highlighted) {
            this.unhighlightMarker(parseInt(prevProps.highlighted))
        }
        if (this.props.highlighted) {
            this.highlightMarker(parseInt(this.props.highlighted))
            if (this.props.building) {
                const buildingId = parseInt(this.props.building.id)
                if (buildingId !== parseInt(this.props.highlighted))
                    this.unhighlightMarker(buildingId)
            }
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

    addMarkers() {}

    get markers() {
        return this.props.buildings && this.props.buildings.map(item => {
            // TODO: forge and miniforge must receive identical array of attributes
            const building = item.data ? item.data.attributes : item;
            const lat = building.lat || building.latitude
            const lon = building.lon || building.longitude
            const marker = new google.maps.Marker({
                position: new google.maps.LatLng(lat, lon),
                icon: this.iconStatic,
                zIndex: 10
            })
            marker.buildingId = building.id
            google.maps.event.addListener(marker, 'click', () => {
                this.handleMarkerClick(building)
            })
            google.maps.event.addListener(marker, 'mouseover', () => {
                this.handleMarkerMouseOver(building)
            })
            google.maps.event.addListener(marker, 'mouseout', () => {
                this.handleMarkerMouseOut(building)
            })
            return marker
        })
    }

    handleMarkerClick(building) {}
    handleMarkerMouseOver(building) {}
    handleMarkerMouseOut(building) {}
    addLayers() {}
    doOpacity() {}
}

export default BaseMap;
