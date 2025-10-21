const google = window.google

export function generateMarkers(items, handlers) {
  if (!items || !Array.isArray(items)) return null

  const markers = {}
  items.forEach(item => {
    if (!item || !item.id) {
      console.warn('Skipping invalid item in generateMarkers:', item);
      return;
    }

    const lat = item.lat || item.latitude
    const lon = item.lon || item.longitude

    if (!lat || !lon || isNaN(lat) || isNaN(lon)) {
      console.warn(`Skipping item ${item.id} with invalid coordinates: lat=${lat}, lon=${lon}`);
      return;
    }

    const marker = new google.maps.Marker({
      position: new google.maps.LatLng(lat, lon),
      icon: getStaticIcon(),
      zIndex: 10
    })
    marker.buildingId = item.id
    google.maps.event.addListener(marker, 'click', () => {
      handlers.onClick(item)
    })
    google.maps.event.addListener(marker, 'mouseover', () => {
      handlers.onMouseOver(item, marker)
    })
    google.maps.event.addListener(marker, 'mouseout', () => {
      handlers.onMouseOut(item)
    })
    markers[marker.buildingId] = marker
  })
  return markers
}

function tweakMarker(id, icon, zIndex, markers) {
  if (!markers) {
    console.warn('Markers object is null or undefined');
    return;
  }
  const marker = markers[id];
  if (!marker) {
    console.warn(`Marker with id ${id} not found`);
    return;
  }
  marker.setIcon(icon)
  marker.setZIndex(zIndex)
}

export function highlightMarker(id, markers) {
  tweakMarker(id, getHoverIcon(), 100, markers)
}

export function unhighlightMarker(id, markers) {
  tweakMarker(id, getStaticIcon(), 10, markers)
}

function getBaseIcon() {
  return {
    path: google.maps.SymbolPath.CIRCLE,
    fillOpacity: 0.9,
    scale: 6,
    strokeColor: '#333',
    strokeWeight: 1
  }
}

function getHoverIcon() {
  return Object.assign({}, getBaseIcon(), {
    fillColor: 'blue'
  })
}

function getStaticIcon() {
  return Object.assign({}, getBaseIcon(), {
    fillColor: 'red'
  })
}

export function getMainIcon() {
  return Object.assign({}, getBaseIcon(), {
    fillColor: 'green',
    scale: 10
  })
}
