import L from 'leaflet'

const staticStyle = {
  radius: 6,
  fillColor: 'red',
  fillOpacity: 0.9,
  color: '#333',
  weight: 1,
}

const hoverStyle = {
  fillColor: 'blue',
}

const mainIconSvg = `
  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="34" viewBox="0 0 20 34">
    <path d="M 10,0 C 8,0 0,1 0,12 C 0,20 10,34 10,34 C 10,34 20,20 20,12 C 20,1 12,0 10,0 Z"
          fill="green" fill-opacity="0.9" stroke="#333" stroke-width="1"/>
  </svg>`

export function getMainIcon() {
  return L.divIcon({
    html: mainIconSvg,
    className: '',
    iconSize: [20, 34],
    iconAnchor: [10, 34],
    popupAnchor: [0, -34],
  })
}

export function generateMarkers(items, handlers) {
  if (!items || !Array.isArray(items)) return null

  const markers = {}
  items.forEach(item => {
    if (!item || !item.id) {
      console.warn('Skipping invalid item in generateMarkers:', item)
      return
    }

    const lat = item.lat || item.latitude
    const lon = item.lon || item.longitude

    if (!lat || !lon || isNaN(lat) || isNaN(lon)) {
      console.warn(`Skipping item ${item.id} with invalid coordinates: lat=${lat}, lon=${lon}`)
      return
    }

    const marker = L.circleMarker([lat, lon], { ...staticStyle })
    marker.buildingId = item.id
    marker.on('click', () => handlers.onClick(item))
    marker.on('mouseover', () => handlers.onMouseOver(item, marker))
    marker.on('mouseout', () => handlers.onMouseOut(item))
    markers[marker.buildingId] = marker
  })
  return markers
}

export function highlightMarker(id, markers) {
  if (!markers) return
  const marker = markers[id]
  if (!marker) return
  marker.setStyle(hoverStyle)
  marker.bringToFront()
}

export function unhighlightMarker(id, markers) {
  if (!markers) return
  const marker = markers[id]
  if (!marker) return
  marker.setStyle({ fillColor: 'red' })
  marker.bringToBack()
}
