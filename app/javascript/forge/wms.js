import L from 'leaflet'

export default function loadWMS(map, layer) {
  const url = layer.url
    .replace(/mosaics\/tile/, 'mosaics/wms')
    .replace('/{z}/{x}/{y}.png', '')
    .split('?')[0]

  return L.tileLayer.wms(url, {
    layers: layer.layers_param ?? 'image',
    format: 'image/png',
    transparent: true,
    opacity: 1,
    version: '1.1.1',
  })
}
