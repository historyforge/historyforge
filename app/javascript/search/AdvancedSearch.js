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
      this.bindFilterDialog(filters)
    } catch (error) {
      if (!this.signal.aborted) console.error('Could not load search filters', error)
    }
  }

  bindFilterDialog(filters) {
    const options = { signal: this.signal }
    const dialog = this.form.querySelector('#newAttributeFilter')
    const conditions = dialog.querySelector('[data-filter-conditions]')
    const template = dialog.querySelector('[data-filter-condition-template]')
    const addButton = dialog.querySelector('[data-add-condition]')
    const groupStorage = dialog.querySelector('[data-filter-group-storage]')
    const groups = [...groupStorage.children]
    const censusScope = groups.find(group => group.dataset.filterGroup === '__census_scope')
    const censusScopeFields = new Set(Array.from(censusScope?.querySelectorAll('[name]') ?? [],
      field => field.name.match(/^s\[(.+)_eq\]$/)?.[1]))
    let originalValues = new Map()
    let applying = false

    const groupFields = group => {
      const fields = [...group.querySelectorAll('input, select')]
      const creator = this.form.elements['s[creator_id]']
      if (group.dataset.filterGroup === '__creation_details' && creator) fields.push(creator)
      return fields
    }

    const returnGroup = group => {
      if (!group) return
      for (const [field, value] of originalValues.get(group) || []) field.value = value
      group.querySelector('#s_creation_date_range')?.dispatchEvent(new Event('change', { bubbles: true }))
      groupStorage.append(group)
    }

    const updateChoices = () => {
      const fields = [...conditions.querySelectorAll('select.attribute')]
      const selected = new Set(fields.map(field => field.value).filter(Boolean))
      addButton.hidden = selected.size === 0
      for (const field of fields) {
        for (const option of field.options) {
          option.disabled = option.value !== field.value && selected.has(option.value)
        }
      }
      addButton.disabled = fields.some(field => !field.value) ||
        selected.size === fields[0]?.options.length - 1
    }

    const addCondition = () => {
      const condition = template.content.firstElementChild.cloneNode(true)
      const field = condition.querySelector('select.attribute')
      field.add(new Option('Select field name', ''))
      if (groups.length) {
        const quickFilters = document.createElement('optgroup')
        quickFilters.label = 'Quick filters'
        for (const group of groups) {
          quickFilters.append(new Option(group.dataset.filterLabel, group.dataset.filterGroup))
        }
        field.append(quickFilters)
      }
      const individualFields = document.createElement('optgroup')
      individualFields.label = 'Individual fields'
      for (const [key, config] of Object.entries(filters)) {
        if (config.scopes && !censusScopeFields.has(key)) individualFields.append(new Option(config.label, key))
      }
      field.append(individualFields)
      const groupSlot = condition.querySelector('[data-condition-group]')
      const removeButton = condition.querySelector('[data-remove-condition]')
      field.addEventListener('change', () => {
        returnGroup(groupSlot.firstElementChild)
        const group = groups.find(item => item.dataset.filterGroup === field.value)
        groupSlot.hidden = !group
        if (group) groupSlot.append(group)
        removeButton.hidden = !field.value
        selectAttribute(condition, filters[field.value])
        updateChoices()
      }, options)
      removeButton.addEventListener('click', () => {
        returnGroup(groupSlot.firstElementChild)
        condition.remove()
        if (conditions.childElementCount === 0) addCondition().focus()
        else {
          updateChoices()
          conditions.querySelector('select.attribute').focus()
        }
      }, options)
      conditions.append(condition)
      updateChoices()
      return field
    }

    addCondition()
    addButton.addEventListener('click', () => addCondition().focus(), options)
    dialog.addEventListener('show.bs.modal', () => {
      originalValues = new Map(groups.map(group => [group, groupFields(group).map(field => [field, field.value])]))
    }, options)
    dialog.addEventListener('shown.bs.modal', () => conditions.querySelector('select.attribute').focus(), options)
    dialog.addEventListener('hidden.bs.modal', () => {
      if (applying) return
      groups.forEach(returnGroup)
      conditions.replaceChildren()
      addCondition()
    }, options)
    this.form.addEventListener('formdata', ({ formData }) => {
      if (!censusScope || !conditions.contains(censusScope)) return

      for (const field of groupFields(censusScope)) {
        if (field.value) formData.set(field.name, field.value)
        else formData.delete(field.name)
      }
    }, options)
    this.form.addEventListener('submit', () => {
      if (!dialog.classList.contains('show')) return
      applying = true
      window.bootstrap.Modal.getInstance(dialog)?.hide()
      applying = false
    }, options)
  }

  bindFormEvents() {
    const options = { signal: this.signal }
    this.form.addEventListener('formdata', ({ formData }) => {
      if (formData.get('scope') === 'on') formData.delete('scope')
      if (formData.get('s[creation_date_range]') === 'all') {
        for (const field of ['range', 'from', 'to']) formData.delete(`s[creation_date_${field}]`)
      }
      for (const name of new Set(formData.keys())) {
        if (!name.startsWith('s[')) continue
        const values = formData.getAll(name)
        let nonempty = values.filter(value => value.trim() !== '')
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
