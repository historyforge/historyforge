import { Controller } from 'stimulus'

const addressFields = {
  locality_id: 'locality_id',
  street: 'street_name',
  house: 'street_house_number',
  prefix: 'street_prefix',
  suffix: 'street_suffix'
}

export default class extends Controller {
  connect() {
    this.select = this.element.querySelector('select[name="census_record[building_id]"]')
    if (!this.select) return

    this.ensureBuilding = this.element.querySelector('.census_record_ensure_building')
    this.fields = Object.fromEntries(Object.entries(addressFields).map(([param, name]) => [
      param, this.element.querySelector(`[name="census_record[${name}]"]`)
    ]))
    const existingId = this.element.querySelector('input[type=hidden][name="census_record[building_id]"]')?.value
    this.updateVisibility()
    this.load(existingId)
  }

  disconnect() {
    this.request?.abort()
  }

  change({ target }) {
    if (!this.select) return
    if (target === this.select) this.updateVisibility()
    if (Object.values(this.fields).includes(target)) this.load()
  }

  updateVisibility() {
    if (this.ensureBuilding) this.ensureBuilding.hidden = !!this.select.value
  }

  async load(existingId) {
    this.request?.abort()
    const params = new URLSearchParams()
    for (const [name, field] of Object.entries(this.fields)) {
      if (field?.value) params.set(name, field.value)
    }
    if (!params.has('locality_id') || !params.has('street')) return

    const request = new AbortController()
    this.request = request
    try {
      const url = this.element.dataset.buildingOptionsUrl
      const response = await fetch(`${url}?${params}`, {
        signal: request.signal, headers: { Accept: 'application/json' }
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      const buildings = await response.json()
      if (request.signal.aborted) return
      const selected = this.select.value || existingId
      this.select.replaceChildren(new Option('Select a building', ''), ...buildings.map(({ id, name }) => new Option(name, id)))
      this.select.value = buildings.some(({ id }) => String(id) === selected) ? selected : ''
      this.updateVisibility()
    } catch (error) {
      if (!request.signal.aborted) console.error('Could not load building choices', error)
    }
  }
}
