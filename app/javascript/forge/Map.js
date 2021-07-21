import React from 'react'
import {connect} from "react-redux";
import loadWMS from "./wms";

class Map extends React.PureComponent {
    state = { map: null }
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

    // TODO: only add the markers when the buildings are different
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
            this.unhighlightMarker(prevProps.highlighted)
        }
        if ((!prevProps.heatmapOpacityAt && this.props.heatmapOpacityAt) || (prevProps.heatmapOpacityAt !== this.props.heatmapOpacityAt)) {
            this.doHeatmapOpacity()
        }
        if (this.props.highlighted) {
            this.highlightMarker(this.props.highlighted)
            if (this.props.building) {
                const buildingId = parseInt(this.props.building.id)
                if (buildingId !== this.props.highlighted)
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

    addMarkers() {
        this.addMarkerCluster()
        // this.addHeatMap()
    }

    addMarkerCluster() {
        if (this.state.heatmap) this.state.heatmap.setMap(null)

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

    addHeatMap() {
        if (this.state.clusterer) this.state.clusterer.clearMarkers()

        const points = this.props.buildings && this.props.buildings.map(building => {
            return {
                location: new google.maps.LatLng(building.lat, building.lon),
                weight: building.weight || 5
            }
        })

        const heatmap = this.state.heatmap || new google.maps.visualization.HeatmapLayer({
            data: points,
            map: this.state.map,
            radius: 50,
            opacity: 0
        })

        this.setState({ heatmap }, () => {
            this.doHeatmapOpacity()
        })
    }

    get markers() {
        return this.props.buildings && this.props.buildings.map(building => {
            const marker = new google.maps.Marker({
                position: new google.maps.LatLng(building.lat, building.lon),
                icon: this.iconStatic,
                zIndex: 10
            })
            marker.buildingId = building.id
            google.maps.event.addListener(marker, 'click', () => {
                this.props.select(building.id, this.props.params)
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
        const selectedLayers = this.props.layers.filter(layer => layer.selected)
        // if (!selectedLayers.length) return

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

    doHeatmapOpacity() {
        const { heatmapOpacity } = this.props
        if (typeof(heatmapOpacity) === 'number')
            this.state.heatmap.set('opacity', heatmapOpacity / 100)
        else
            this.state.heatmap.set('opacity', 100)
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
