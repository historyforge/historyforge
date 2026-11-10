const censusForm = '#new_census_record, #edit_census_record'

function toggleDependents(input) {
  const attribute = input.name.match(/census_record\[(\w+)\]/)?.[1]
  if (!attribute) return
  const value = input.type === 'checkbox' ? input.checked : input.value
  const active = String(value) === input.closest('[data-dependents]').dataset.dependents
  input.form.querySelectorAll(`[data-depends-on="${attribute}"]`).forEach(wrapper => {
    wrapper.classList.toggle('disabled', !active)
    wrapper.querySelectorAll('input').forEach(field => { field.disabled = !active })
  })
}

document.addEventListener('turbo:load', () => {
  document.querySelectorAll(censusForm).forEach(form => {
    form.querySelectorAll('[data-type=other-radio-button]').forEach(input => { input.disabled = !input.value.length })
    form.querySelectorAll('[data-dependents] :is(input[type=radio]:checked, input[type=checkbox], input[type=text])')
      .forEach(toggleDependents)
  })
})

document.addEventListener('keypress', event => {
  if (event.key === 'Enter' && event.target.closest(censusForm)) event.preventDefault()
})

document.addEventListener('click', ({ target }) => {
  if (!target.closest(censusForm)) return
  if (target.matches('[data-dependents] input')) toggleDependents(target)
  if (!target.matches('input[type=radio]')) return
  const other = target.closest('.form-group')?.querySelector('[data-type=other-radio-button]')
  if (other) {
    const selected = target.closest('.form-check')?.contains(other)
    other.disabled = !selected
    if (selected) other.focus()
    else other.value = ''
  }
  if (target.name === 'census_record[war_fought]') {
    const veteran = document.getElementById('census_record_veteran')
    if (veteran) veteran.checked = !!target.value && target.value !== 'on'
  }
})

document.addEventListener('change', ({ target }) => {
  if (target.matches('[data-dependents] input')) toggleDependents(target)
  if (target.matches('[data-type=other-radio-button]')) {
    const radio = target.closest('.form-check')?.querySelector('input[type=radio]')
    if (radio) {
      radio.checked = true
      radio.value = target.value
    }
  }
  if (target.id === 'census_record_page_side') {
    const line = document.getElementById('census_record_line_number')
    if (line) {
      line.min = target.value === 'A' ? 1 : 51
      line.max = target.value === 'A' ? 50 : 100
    }
  }
  if (target.id === 'census_record_sex' && ['M', 'F'].includes(target.value)) {
    for (const field of ['born', 'alive']) {
      const input = document.getElementById('census_record_num_children_' + field)
      if (!input) continue
      input.disabled = target.value === 'M'
      if (input.disabled) input.value = ''
    }
  }
  if (target.id === 'census_record_marital_status') {
    const years = document.getElementById('census_record_years_married')
    if (years) {
      years.disabled = ['S', 'D'].includes(target.value)
      if (years.disabled) years.value = ''
    }
  }
})
