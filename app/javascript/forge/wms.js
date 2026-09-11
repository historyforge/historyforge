import L from 'leaflet'

export default function loadWMS(map, layer) {
  // Keep historical maps above either basemap, including after layer switches.
  if (!map.getPane('historicalMaps')) {
    map.createPane('historicalMaps').style.zIndex = 250
  }
  const url = layer.url
    .replace(/mosaics\/tile/, 'mosaics/wms')
    .replace('/{z}/{x}/{y}.png', '')
    .split('?')[0]

  return L.tileLayer.wms(url, {
    pane: 'historicalMaps',
    layers: layer.layers_param ?? 'image',
    format: 'image/png',
    transparent: true,
    opacity: 1,
    version: '1.1.1',
    maxZoom: 22,
  })
}
