import { Controller } from 'stimulus'
import { loadMaps } from '../loadMaps'

function parseCoordinates(latitude, longitude) {
  if (!String(latitude ?? '').trim() || !String(longitude ?? '').trim()) return null
  const lat = Number(latitude)
  const lon = Number(longitude)
  if (!Number.isFinite(lat) || !Number.isFinite(lon) || Math.abs(lat) > 90 || Math.abs(lon) > 180) return null
  return [lat, lon]
}

export default class extends Controller {
  connect() {
    this.listeners = new AbortController()
    this.selectFilters = new Map()
    const options = { signal: this.listeners.signal }
    this.element.addEventListener('click', event => this.click(event), options)
    this.element.addEventListener('change', event => this.change(event.target), options)
    this.element.addEventListener('autocomplete:selected', event => this.addAssociation(event), options)
    document.addEventListener('turbo:before-cache', () => this.disconnect(), options)

    this.paramKey = this.element.getAttribute('action')?.match(/\/(photographs|audios|videos|narratives)(?:\/|$)/)?.[1].slice(0, -1)
    if (this.element.id === 'photo-wizard') {
      const steps = [...this.element.querySelectorAll(':scope > .card')]
      steps.forEach((step, index) => {
        const title = document.createElement('h3')
        title.className = 'card-title'
        title.dataset.turboTemporary = ''
        title.textContent = `Step ${index + 1} of ${steps.length}`
        step.querySelector('.card-body').prepend(title)
      })
      window.scrollTo(0, 0)
    }
    this.addSelectFilters()
  }

  disconnect() {
    this.listeners?.abort()
    this.mapListeners?.abort()
    this.map?.remove()
    this.map = null
    this.mapInitialized = false
    for (const [select, filter] of this.selectFilters) {
      filter.remove()
      for (const option of select.options) option.hidden = false
    }
    this.selectFilters.clear()
  }

  click(event) {
    const button = event.target.closest('button')
    if (!button) return

    if (button.matches('.btn-next, .btn-prev')) {
      const card = button.closest('.card')
      const next = button.matches('.btn-next') ? card.nextElementSibling : card.previousElementSibling
      if (!next?.matches('.card')) return
      card.classList.remove('active')
      next.classList.add('active')
      window.scrollTo(0, 0)
      if (next.querySelector('#photograph-map') && !this.mapInitialized) {
        this.initMap(next).catch(error => console.error('Could not initialize the photo map', error))
      }
    } else if (button.matches('#dates-question [data-date-type]')) {
      for (const choice of this.element.querySelectorAll('#dates-question [data-date-type]')) {
        choice.classList.toggle('btn-primary', choice === button)
        choice.classList.toggle('btn-light', choice !== button)
      }
      this.element.querySelector('#photograph_date_type').value = button.dataset.dateType
      this.element.querySelector('#photograph-date-type').className = button.dataset.dateType
    } else if (button.matches('#person-question .btn-primary, #building-question .btn-primary')) {
      const question = button.closest('#person-question, #building-question')
      question.hidden = true
      const fields = this.element.querySelector('#' + question.id.replace('question', 'fields'))
      fields.style.display = ''
      fields.querySelector('[data-controller=autocomplete]')?.focus()
    }
    this.addSelectFilters()
  }

  change(input) {
    const nextButtons = this.element.querySelectorAll('.step-1-next-button')
    if (input.matches('#audio_remote_url, #video_remote_url, #photograph_remote_url')) {
      nextButtons.forEach(button => { button.disabled = !input.value.length })
    } else if (input.matches('#photograph_file') && input.files.length) {
      const reader = new FileReader()
      reader.onload = () => {
        if (!input.isConnected || this.listeners.signal.aborted) return
        for (const preview of this.element.querySelectorAll('#selected-file, .thumb')) {
          const image = document.createElement('img')
          image.src = reader.result
          image.alt = ''
          image.className = 'img img-thumbnail'
          preview.replaceChildren(image)
        }
        nextButtons.forEach(button => { button.disabled = false })
      }
      reader.readAsDataURL(input.files[0])
    }
  }

  addSelectFilters() {
    for (const select of this.element.querySelectorAll('select')) {
      if (!select.offsetParent || select.options.length < 15 || this.selectFilters.has(select)) continue
      const search = document.createElement('input')
      search.type = 'search'
      search.className = 'form-control mb-1'
      search.placeholder = 'Filter choices'
      search.setAttribute('aria-label', 'Filter choices for ' + (select.labels[0]?.textContent.trim() || select.name))
      search.addEventListener('keydown', event => {
        if (event.key === 'Enter') {
          event.preventDefault()
          select.focus()
        }
      })
      search.addEventListener('input', () => {
        const term = search.value.toLowerCase()
        for (const option of select.options) {
          option.hidden = !option.selected && !option.text.toLowerCase().includes(term)
        }
      })
      select.before(search)
      this.selectFilters.set(select, search)
    }
  }

  addAssociation({ target, detail: item }) {
    const type = target.dataset.autocompleteKind === 'media-person' ? 'person' : 'building'
    const wrapper = this.element.querySelector(`.${this.paramKey}_${type}_ids`)
    if (!wrapper) return
    const id = `${this.paramKey}_${type}_ids_${item.id}`
    document.getElementById(id)?.closest('.form-check')?.remove()

    const option = document.createElement('div')
    option.className = 'form-check'
    const input = document.createElement('input')
    Object.assign(input, { type: 'checkbox', className: 'form-check-input', id,
      name: `${this.paramKey}[${type}_ids][]`, value: item.id, checked: true, defaultChecked: true })
    const label = document.createElement('label')
    label.className = 'form-check-label'
    label.htmlFor = id
    label.textContent = type === 'person' ? `${item.name} (${item.id}) - ${item.years}` : item.address
    option.append(input, label)
    wrapper.append(option)
    target.value = ''

    const lat = this.element.querySelector('#photograph_latitude')
    const lon = this.element.querySelector('#photograph_longitude')
    if (type === 'building' && lat && lon && wrapper.querySelectorAll('input:checked').length === 1) {
      lat.value = item.lat ?? ''
      lon.value = item.lon ?? ''
      lon.dispatchEvent(new Event('change', { bubbles: true }))
    }
  }

  async initMap(card) {
    const { L, createStreetLayer, getMainIcon } = await loadMaps()
    if (this.listeners.signal.aborted || !card.isConnected || !card.classList.contains('active') || this.mapInitialized) return

    const startLat = document.getElementById('photograph_latitude').value
    const startLon = document.getElementById('photograph_longitude').value
    const loc = parseCoordinates(startLat, startLon)
      || JSON.parse(document.getElementById('photograph-map').dataset.center)

    const map = L.map('photograph-map', {
      center: loc,
      zoom: 13,
    })
    this.mapListeners = new AbortController()
    this.map = map
    this.mapInitialized = true

    createStreetLayer().addTo(map)

    const marker = L.marker(loc, {
      icon: getMainIcon(),
      draggable: true,
    }).addTo(map)

    marker.on('dragend', function () {
      const position = marker.getLatLng()
      document.getElementById('photograph_latitude').value = position.lat
      document.getElementById('photograph_longitude').value = position.lng
    })

    this.updateMapCoordinates = () => {
      const lat = document.getElementById('photograph_latitude').value
      const lon = document.getElementById('photograph_longitude').value
      const latlng = parseCoordinates(lat, lon)
      if (!latlng) return
      marker.setLatLng(latlng)
      map.setView(latlng)
    }
    this.element.querySelectorAll('#photograph_latitude, #photograph_longitude').forEach(input => {
      input.addEventListener('change', this.updateMapCoordinates, { signal: this.mapListeners.signal })
    })
  }
}
