import addAttributeFilter from './addAttributeFilter'
import selectAttribute from './selectAttribute'

export default class AdvancedSearch {
  constructor(form, url, filters, signal) {
    this.form = form
    this.filters = filters
    this.signal = signal
    this.bindFormEvents()
    this.loadFilters(url)
  }

  async loadFilters(url) {
    try {
      const response = await fetch(url, { signal: this.signal, headers: { Accept: 'application/json' } })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      const { filters } = await response.json()
      if (this.signal.aborted) return

      const chips = this.form.querySelector('#attribute-filters')
      chips.querySelectorAll(':scope > :not([data-creator-filter-chip])').forEach(chip => chip.remove())
      for (const [scope, value] of Object.entries(this.filters)) {
        const config = Object.values(filters).find(field => field.scopes?.[scope])
          || Object.values(filters).find(field => field.scopes?.[scope.replace(/_eq/, '_in')])
        if (config) addAttributeFilter(chips, this.form, config, scope, value)
      }
      chips.classList.toggle('mb-3', chips.children.length > 0)

      const attribute = this.form.querySelector('select.attribute')
      attribute.replaceChildren(new Option('Select field name', ''))
      for (const [key, config] of Object.entries(filters)) {
        if (config.scopes) attribute.add(new Option(config.label, key))
      }
      attribute.addEventListener('change', () => {
        selectAttribute(this.form, filters[attribute.value])
      }, { signal: this.signal })
    } catch (error) {
      if (!this.signal.aborted) console.error('Could not load search filters', error)
    }
  }

  bindFormEvents() {
    const options = { signal: this.signal }
    this.form.addEventListener('formdata', ({ formData }) => {
      for (const name of new Set(formData.keys())) {
        if (!name.startsWith('s[')) continue
        const values = formData.getAll(name)
        let nonempty = values.filter(value => value !== '')
        if (nonempty.length > 1 && nonempty.every(value => value === nonempty[0])) nonempty = [nonempty[0]]
        if (nonempty.length === values.length) continue
        formData.delete(name)
        nonempty.forEach(value => formData.append(name, value))
      }
      if (!formData.has('f[]')) formData.set('f', '')
    }, options)

    this.form.querySelectorAll('[data-clear-creator-filter]').forEach(button => {
      button.addEventListener('click', () => {
        if (button.dataset.clearCreatorFilter === 'creator') {
          this.form.querySelectorAll('[name="s[creator_id]"], #creator_lookup').forEach(input => { input.value = '' })
        } else {
          this.form.elements['s[creation_date_range]'].value = 'all'
          for (const field of ['from', 'to']) this.form.elements[`s[creation_date_${field}]`].value = ''
        }
        this.form.requestSubmit()
      }, options)
    })

    this.form.querySelector('.checkall').addEventListener('click', event => {
      const inputs = [...this.form.querySelectorAll(`${event.currentTarget.dataset.scope} input[type=checkbox]`)]
      const restoreDefaults = inputs.every(input => input.checked)
      inputs.forEach(input => { input.checked = !restoreDefaults || input.dataset.default === 'true' })
    }, options)
  }
}
