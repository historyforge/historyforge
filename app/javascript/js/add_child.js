let nextChildId = 0

document.addEventListener('click', event => {
  const remove = event.target.closest('.nested-form-item .remove')
  if (remove) {
    event.preventDefault()
    const item = remove.closest('.nested-form-item')
    const destroy = item.querySelector('[name*="_destroy"]')
    if (destroy) {
      destroy.value = '1'
      item.classList.add('removed')
    } else {
      item.remove()
    }
    return
  }

  const button = event.target.closest('[data-insert-fields]')
  if (!button) return
  const { insertFields, formSelector } = button.dataset
  const template = document.getElementById(insertFields + '_fields')
  if (!template) return
  const form = formSelector ? document.querySelector(formSelector) : button.closest('.nested-form')
  const target = form?.querySelector(':scope > .nested-form-items')
  const association = insertFields.replace(/_[^_]+$/, '')
  target?.insertAdjacentHTML('beforeend', template.innerHTML.replaceAll('new_' + association, Date.now() + ++nextChildId))
  target?.querySelector('.nested-form-item:last-child')?.classList.remove('collapsed')
})
