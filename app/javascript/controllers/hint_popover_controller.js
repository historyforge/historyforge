import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    const group = this.element.closest('.form-group')
    const label = group?.querySelector(':scope > label, :scope > .col-form-label')
    if (!label || label.querySelector('.fa-question-circle')) return

    const title = label.textContent.trim()
    this.icon = document.createElement('i')
    this.icon.className = 'fa fa-question-circle float-right'
    this.icon.setAttribute('aria-hidden', 'true')
    this.icon.dataset.bsToggle = 'popover'
    label.prepend(this.icon)

    const { Popover } = window.bootstrap
    this.popover = new Popover(this.icon, {
      animation: false,
      container: 'body',
      html: true,
      title,
      content: this.element.innerHTML,
      trigger: 'hover'
    })

    this.icon.addEventListener('show.bs.popover', () => {
      document.querySelectorAll('[data-bs-toggle=popover]').forEach(element => {
        if (element !== this.icon) Popover.getInstance(element)?.hide()
      })
    })
    this.icon.addEventListener('click', event => event.preventDefault())
    this.fieldEvents = new AbortController()
    const { signal } = this.fieldEvents
    group.addEventListener('focusout', event => {
      if (event.target.matches('input, select, textarea')) this.popover.hide()
    }, { signal })
    group.addEventListener('keydown', event => {
      if (event.key === 'F1' && event.target.matches('input, select, textarea')) {
        event.preventDefault()
        this.popover.show()
      }
      if (event.key === 'Escape') this.popover.hide()
    }, { signal })
  }

  disconnect() {
    this.fieldEvents?.abort()
    this.popover?.hide()
    this.popover?.dispose()
    this.icon?.remove()
    this.popover = null
    this.icon = null
  }
}
