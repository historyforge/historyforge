export function generateMarkers(items, handlers) {
  if (!items || !Array.isArray(items)) return null
  const google = window.google;
  if (!google || !google.maps) {
    console.error('Google Maps API not available');
    return null;
  }

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
      icon: getStaticIcon(google),
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
  const google = window.google;
  if (!google || !google.maps) return;
  tweakMarker(id, getHoverIcon(google), 100, markers)
}

export function unhighlightMarker(id, markers) {
  const google = window.google;
  if (!google || !google.maps) return;
  tweakMarker(id, getStaticIcon(google), 10, markers)
}

function getBaseIcon(google) {
  return {
    path: google.maps.SymbolPath.CIRCLE,
    fillOpacity: 0.9,
    scale: 6,
    strokeColor: '#333',
    strokeWeight: 1
  }
}

function getHoverIcon(google) {
  return Object.assign({}, getBaseIcon(google), {
    fillColor: 'blue'
  })
}

function getStaticIcon(google) {
  return Object.assign({}, getBaseIcon(google), {
    fillColor: 'red'
  })
}

export function getMainIcon() {
  const google = window.google;
  if (!google || !google.maps) {
    return {
      path: 'M 0,0 C -2,-20 -10,-22 -10,-30 A 10,10 0 1,1 10,-30 C 10,-22 2,-20 0,0 z',
      fillColor: 'green',
      fillOpacity: 0.9,
      scale: 10,
      strokeColor: '#333',
      strokeWeight: 1
    };
  }
  return Object.assign({}, getBaseIcon(google), {
    fillColor: 'green',
    scale: 10
  })
}
