import L from 'leaflet'
import { setWorkerUrl } from 'maplibre-gl'
import '@maplibre/maplibre-gl-leaflet'
import { addStyleImageMissingFallback } from './maplibreImageFallback'
import { addHousenumbers } from './maplibreHousenumbers'

export function createStreetLayer() {
  // Rails supplies the fingerprinted URL for MapLibre 6's separate worker.
  setWorkerUrl(document.querySelector('meta[name="maplibre-worker-url"]').content)
  const layer = L.maplibreGL({
    style: 'https://tiles.openfreemap.org/styles/liberty',
    maxZoom: 22,
    // The wrapper forwards this to Leaflet instead of untrusted source metadata.
    attributionControl: {
      customAttribution: '&copy; <a href="https://openfreemap.org">OpenFreeMap</a> &copy; <a href="https://openmaptiles.org">OpenMapTiles</a> Data from <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    },
  })

  // The wrapper creates a fresh MapLibre map on every Street layer activation.
  layer.on('add', () => {
    const map = layer.getMaplibreMap()
    addStyleImageMissingFallback(map)
    addHousenumbers(map)
  })
  return layer
}
