import isValuelessPredicate from './isValuelessPredicate'

export default function selectAttribute(condition, config) {
  const scopeContainer = condition.querySelector('.scope-selection-container')
  const valueBox = condition.querySelector('.value-input-container')
  scopeContainer.replaceChildren()
  valueBox.replaceChildren()
  if (!config) return

  const scopes = Object.entries(config.scopes)
  const selector = document.createElement('select')
  selector.className = 'scope form-control'
  selector.setAttribute('aria-label', 'Filter comparison')
  scopes.forEach(([value, label]) => selector.add(new Option(label, value)))
  if (scopes.length === 1) {
    selector.hidden = true
    scopeContainer.append(scopes[0][1])
  }
  scopeContainer.append(selector)
  valueBox.className = `value-input-container col-md ${config.type}`
  if (config.columns) valueBox.classList.add(`column-count-${config.columns}`)

  const renderValue = () => {
    const name = `s[${selector.value}]`
    const previous = valueBox.querySelector('input:not([type=hidden]):not([type=checkbox]), select')?.value
    const writeIns = [...valueBox.querySelectorAll('[data-write-in]')].map(field => field.value)
    const checked = new Set([...valueBox.querySelectorAll('input[type=checkbox]:checked')].map(input => input.value))
    valueBox.replaceChildren()

    if (isValuelessPredicate(selector.value) || config.type === 'boolean') {
      valueBox.append(input(name, 'hidden', '1'))
    } else if (config.type === 'checkboxes') {
      for (const choice of config.choices) {
        const [label, value] = Array.isArray(choice) ? choice : [choice, choice]
        const wrapper = document.createElement('label')
        wrapper.className = 'form-check d-block'
        const checkbox = input(name + '[]', 'checkbox', value)
        checkbox.className = 'form-check-input'
        checkbox.checked = checked.has(checkbox.value)
        wrapper.append(checkbox, label)
        valueBox.append(wrapper)
        if (value === '__race_write_in__') {
          addWriteInFields(valueBox, checkbox, name, writeIns)
        }
      }
    } else {
      const field = config.type === 'dropdown' ? document.createElement('select')
        : input(name, config.type === 'text' ? 'text' : 'number', previous ?? '')
      field.name = name
      field.className = 'form-control'
      field.setAttribute('aria-label', `${config.label} value`)
      if (config.type === 'dropdown') {
        config.choices.filter(choice => typeof choice === 'string').forEach(choice => field.add(new Option(choice)))
        if (previous && [...field.options].some(option => option.value === previous)) field.value = previous
      }
      if (/y_term/.test(selector.value)) field.placeholder = 'spaces separate "multiple words"'

      if (config.append) {
        const wrapper = document.createElement('div')
        wrapper.className = 'input-append'
        const suffix = document.createElement('span')
        suffix.className = 'add-on'
        suffix.textContent = config.append
        wrapper.append(field, suffix)
        valueBox.append(wrapper)
      } else {
        valueBox.append(field)
      }
    }
  }

  selector.addEventListener('change', () => {
    renderValue()
    valueBox.querySelector('input:not([type=hidden]):not([type=checkbox])')?.focus()
  })
  renderValue()
}

function input(name, type, value) {
  const field = document.createElement('input')
  Object.assign(field, { name, type, value })
  return field
}

function addWriteInFields(container, checkbox, name, values) {
  const editor = document.createElement('div')
  const rows = document.createElement('div')
  const add = document.createElement('button')
  add.type = 'button'
  add.className = 'btn btn-sm btn-outline-secondary'
  add.dataset.addWriteIn = ''
  add.textContent = 'Add another write-in'
  editor.append(rows, add)
  container.append(editor)

  function update() {
    editor.hidden = !checkbox.checked
    const fields = [...rows.querySelectorAll('input')]
    checkbox.name = fields.some(field => field.value.trim()) ? '' : name + '[]'
    for (const field of fields) field.disabled = !checkbox.checked
    for (const button of rows.querySelectorAll('button')) button.hidden = fields.length === 1
  }

  function addRow(value = '') {
    const row = document.createElement('div')
    row.className = 'd-flex gap-2 mb-2'
    const field = input(name + '[]', 'text', value)
    field.dataset.writeIn = ''
    field.className = 'form-control'
    field.placeholder = 'Any write-in'
    field.setAttribute('aria-label', 'Other race as recorded')
    field.addEventListener('input', update)
    field.addEventListener('change', () => { field.value = field.value.trim() })
    const remove = document.createElement('button')
    remove.type = 'button'
    remove.className = 'btn btn-sm btn-outline-secondary'
    remove.textContent = 'Remove write-in'
    remove.addEventListener('click', () => {
      row.remove()
      update()
      rows.querySelector('input').focus()
    })
    row.append(field, remove)
    rows.append(row)
    update()
    return field
  }

  for (const value of values.length ? values : ['']) addRow(value)
  add.addEventListener('click', () => addRow().focus())
  checkbox.addEventListener('change', () => {
    update()
    if (checkbox.checked) rows.querySelector('input').focus()
  })
}
