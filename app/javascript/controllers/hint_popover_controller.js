import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    const label = this.element.closest('.form-group')?.querySelector(':scope > label, :scope > .col-form-label')
    if (!label || label.querySelector('.fa-question-circle')) return

    const title = label.textContent.trim()
    this.icon = document.createElement('i')
    this.icon.className = 'fa fa-question-circle float-right'
    this.icon.tabIndex = 0
    this.icon.setAttribute('aria-label', 'Help for ' + title)
    this.icon.dataset.bsToggle = 'popover'
    label.prepend(this.icon)

    const { Popover } = window.bootstrap
    this.popover = new Popover(this.icon, {
      animation: false,
      container: 'body',
      html: true,
      title,
      content: this.element.innerHTML,
      trigger: 'hover focus'
    })

    this.icon.addEventListener('show.bs.popover', () => {
      document.querySelectorAll('[data-bs-toggle=popover]').forEach(element => {
        if (element !== this.icon) Popover.getInstance(element)?.hide()
      })
    })
    this.icon.addEventListener('click', event => event.preventDefault())
    this.icon.addEventListener('keydown', event => {
      if (event.key === 'Escape') this.popover.hide()
    })
  }

  disconnect() {
    this.popover?.hide()
    this.popover?.dispose()
    this.icon?.remove()
    this.popover = null
    this.icon = null
  }
}
