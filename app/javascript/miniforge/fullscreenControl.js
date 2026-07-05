import L from 'leaflet'

const requestFullscreen = (element) => {
  const method = element.requestFullscreen || element.webkitRequestFullscreen
  return method?.call(element)
}

const exitFullscreen = () => {
  const method = document.exitFullscreen || document.webkitExitFullscreen
  return method?.call(document)
}

export const fullscreenElement = () => document.fullscreenElement || document.webkitFullscreenElement

export const exitMapFullscreen = () => {
  if (fullscreenElement()) {
    exitFullscreen()
  }
}

const isFullscreen = (container) => fullscreenElement() === container

const toggleFullscreen = (container, map) => {
  if (isFullscreen(container)) {
    exitFullscreen()
  } else {
    requestFullscreen(container)
  }
}

export const addFullscreenControl = (map, container) => {
  if (!container) return null
  const canFullscreen = document.fullscreenEnabled || document.webkitFullscreenEnabled
  if (!canFullscreen) return null

  const control = L.Control.extend({
    onAdd() {
      const wrapper = L.DomUtil.create('div', 'leaflet-bar leaflet-control leaflet-control-fullscreen')
      const button = L.DomUtil.create('a', '', wrapper)
      button.href = '#'
      button.title = 'Full screen'
      button.setAttribute('role', 'button')
      button.setAttribute('aria-label', 'Full screen')
      button.innerHTML = '<i class="fa fa-arrows-alt" aria-hidden="true"></i>'

      const updateButton = () => {
        const active = isFullscreen(container)
        button.title = active ? 'Exit full screen' : 'Full screen'
        button.setAttribute('aria-label', button.title)
        button.innerHTML = active
          ? '<i class="fa fa-compress" aria-hidden="true"></i>'
          : '<i class="fa fa-arrows-alt" aria-hidden="true"></i>'
      }

      const onFullscreenChange = () => {
        updateButton()
        setTimeout(() => map.invalidateSize(), 100)
        if (isFullscreen(container)) {
          map.scrollWheelZoom.enable()
        } else {
          map.scrollWheelZoom.disable()
        }
      }

      document.addEventListener('fullscreenchange', onFullscreenChange)
      document.addEventListener('webkitfullscreenchange', onFullscreenChange)

      L.DomEvent.disableClickPropagation(wrapper)
      L.DomEvent.on(button, 'click', (event) => {
        L.DomEvent.stopPropagation(event)
        L.DomEvent.preventDefault(event)
        toggleFullscreen(container, map)
      })

      this._onFullscreenChange = onFullscreenChange
      return wrapper
    },
    onRemove() {
      document.removeEventListener('fullscreenchange', this._onFullscreenChange)
      document.removeEventListener('webkitfullscreenchange', this._onFullscreenChange)
    },
  })

  return new control({ position: 'topright' }).addTo(map)
}
