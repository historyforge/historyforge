import React from 'react'

class BaseMap extends React.PureComponent<MapProps> {
    state: keyable = { map: null }

    iconBase = {
        path: google.maps.SymbolPath.CIRCLE,
        fillOpacity: 0.9,
        scale: 6,
        strokeColor: '#333',
        strokeWeight: 1
    }

    iconHover = Object.assign({}, this.iconBase, {
        fillColor: 'blue',
    })

    iconStatic = Object.assign({}, this.iconBase, {
        fillColor: 'red',
    })

    render(): JSX.Element {
        return null;
    }

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
        this.doMarkerHighlighting(prevProps)
        this.processUpdates(prevProps)
    }

    processUpdates(prevProps) {}

    doMarkerHighlighting(prevProps) {
        const wasHighlighted = parseInt(prevProps.highlighted)
        const isHighlighted = parseInt(this.props.highlighted)
        const buildingId = this.props.building && parseInt(this.props.building.id)
        if (wasHighlighted && wasHighlighted !== isHighlighted) {
            this.unhighlightMarker(wasHighlighted)
        }
        if (isHighlighted) {
            this.highlightMarker(isHighlighted)
        } else if (buildingId) {
            this.highlightMarker(buildingId)
        }
    }

    propertyChanged(prevProps, property) {
        return (!prevProps[property] && this.props[property]) || (prevProps[property] !== this.props[property]);
    }

    markersChanged(prevProps) {
        return this.propertyChanged(prevProps, 'loadedAt')
    }

    opacityChanged(prevProps) {
        return this.propertyChanged(prevProps, 'opacityAt')
    }

    layersChanged(prevProps) {
        return this.propertyChanged(prevProps, 'layeredAt')
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
            const building = item.data ? item.data.attributes : item
            const lat = building.lat || building.latitude
            const lon = building.lon || building.longitude
            const marker = new google.maps.Marker({
                position: new google.maps.LatLng(lat, lon),
                icon: this.iconStatic,
                zIndex: 10
            })
            marker.buildingId = building.id
            google.maps.event.addListener(marker, 'click', () => {
                this.handleMarkerClick(building, marker)
            })
            google.maps.event.addListener(marker, 'mouseover', () => {
                this.handleMarkerMouseOver(building, marker)
            })
            google.maps.event.addListener(marker, 'mouseout', () => {
                this.handleMarkerMouseOut(building, marker)
            })
            return marker
        })
    }

    handleMarkerClick(building, marker) {}
    handleMarkerMouseOver(building, marker) {}
    handleMarkerMouseOut(building, marker) {}
    addLayers() {}
    doOpacity() {}
}

export default BaseMap;
