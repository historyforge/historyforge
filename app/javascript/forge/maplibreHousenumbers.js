const HOUSENUMBER_LAYER = {
  id: 'housenumber',
  type: 'symbol',
  source: 'openmaptiles',
  'source-layer': 'housenumber',
  minzoom: 17,
  filter: ['match', ['geometry-type'], ['MultiPoint', 'Point'], true, false],
  layout: {
    'text-field': ['to-string', ['get', 'housenumber']],
    'text-font': ['Noto Sans Regular'],
    'text-size': 11,
  },
  paint: {
    'text-color': '#443322',
    'text-halo-color': 'rgba(255, 255, 255, 0.85)',
    'text-halo-width': 1.2,
  },
}

/**
 * Adds house number labels to a MapLibre GL map using the openmaptiles source.
 * OpenFreeMap styles omit this layer even though the vector tiles include it.
 */
export function addHousenumbers(maplibreMap) {
  if (!maplibreMap || !maplibreMap.on) return

  const addLayer = () => {
    if (maplibreMap.getLayer('housenumber')) return
    if (!maplibreMap.getSource('openmaptiles')) return

    const beforeId = maplibreMap.getLayer('label_other') ? 'label_other' : undefined
    maplibreMap.addLayer(HOUSENUMBER_LAYER, beforeId)
  }

  if (maplibreMap.isStyleLoaded()) {
    addLayer()
  } else {
    maplibreMap.once('load', addLayer)
  }
}
