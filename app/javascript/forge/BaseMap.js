import React from 'react'

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
        if (this.layersChanged(prevProps)) {
            this.addLayers()
        }
        if (this.opacityChanged(prevProps)) {
            this.doOpacity()
        }
        if (this.markersChanged(prevProps)) {
            this.addMarkers()
        }
        this.doMarkerHighlighting(prevProps);
    }

    doMarkerHighlighting(prevProps) {
        const wasHighlighted = prevProps.highlighted && parseInt(prevProps.highlighted)
        const isHighlighted = this.props.highlighted && parseInt(this.props.highlighted)
        const buildingId = this.props.building && parseInt(this.props.building.id)
        if (wasHighlighted && wasHighlighted !== isHighlighted) {
            this.unhighlightMarker(wasHighlighted)
        }
        if (isHighlighted) {
            this.highlightMarker(isHighlighted)
            if (buildingId) {
                if (buildingId !== isHighlighted)
                    this.unhighlightMarker(buildingId)
            }
        } else if (buildingId) {
            this.highlightMarker(buildingId)
        }
    }

    markersChanged(prevProps) {
        return (!prevProps.loadedAt && this.props.loadedAt) || (prevProps.loadedAt !== this.props.loadedAt);
    }

    opacityChanged(prevProps) {
        return (!prevProps.opacityAt && this.props.opacityAt) || (prevProps.opacityAt !== this.props.opacityAt);
    }

    layersChanged(prevProps) {
        return (!prevProps.layeredAt && this.props.layeredAt) || (prevProps.layeredAt !== this.props.layeredAt)
    }

    highlightMarker(id) {
        this.tweakMarker(id, this.iconHover, 100)
    }

    unhighlightMarker(id) {
        this.tweakMarker(id, this.iconStatic, 10)
    }

    tweakMarker(id, icon, zIndex) {
        const marker = this.state.markers.find(item => item.buildingId === id)
        marker.setIcon(icon)
        marker.setZIndex(zIndex)
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
