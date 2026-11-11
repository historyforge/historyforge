import isValuelessPredicate from './isValuelessPredicate'

export default function selectAttribute(form, config) {
  const scopeContainer = form.querySelector('.scope-selection-container')
  const valueBox = form.querySelector('.value-input-container')
  scopeContainer.replaceChildren()
  valueBox.replaceChildren()
  if (!config) return

  const scopes = Object.entries(config.scopes)
  const selector = document.createElement('select')
  selector.className = 'scope form-control'
  scopes.forEach(([value, label]) => selector.add(new Option(label, value)))
  if (scopes.length === 1) {
    selector.hidden = true
    scopeContainer.append(scopes[0][1])
  }
  scopeContainer.append(selector)
  valueBox.className = `value-input-container col-6 ${config.type}`
  if (config.columns) valueBox.classList.add(`column-count-${config.columns}`)

  const renderValue = () => {
    const name = `s[${selector.value}]`
    const previous = valueBox.querySelector('input:not([type=hidden]):not([type=checkbox]), select')?.value
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
      }
    } else {
      const field = config.type === 'dropdown' ? document.createElement('select')
        : input(name, config.type === 'text' ? 'text' : 'number', previous ?? '')
      field.name = name
      field.className = 'form-control'
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
