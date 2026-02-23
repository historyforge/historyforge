/**
 * Attaches a styleimagemissing handler to a MapLibre GL map.
 * OpenFreeMap and other vector styles may reference sprites that fail to load.
 * This adds transparent 1x1 placeholders for missing images to prevent console errors.
 */
export function addStyleImageMissingFallback(maplibreMap) {
  if (!maplibreMap || !maplibreMap.on) return
  maplibreMap.on('styleimagemissing', (e) => {
    try {
      const data = new Uint8Array(4)
      data[3] = 0
      maplibreMap.addImage(e.id, { width: 1, height: 1, data })
    } catch (_err) {
      // Image may already exist from a prior load
    }
  })
}
