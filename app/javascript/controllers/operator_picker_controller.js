import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['id', 'lookup', 'toggle']

  connect() {
    if (!this.hasLookupTarget) return

    $(this.lookupTarget).autoComplete({
      minChars: 2,
      delay: 250,
      cache: 0,
      source: (term, respond) => {
        this.request?.abort()
        this.request = $.getJSON(this.lookupTarget.dataset.url, { term }, respond)
      },
      renderItem: ({ id, name, login }) => $('<div>', { class: 'autocomplete-suggestion' })
        .attr({ 'data-id': id, 'data-val': name })
        .text(`${name === login ? name : `${name} (${login})`} · #${id}`)[0].outerHTML,
      onSelect: (_event, _name, item) => {
        this.idTarget.value = item.attr('data-id')
        this.lookupTarget.value = item.attr('data-val')
        this.updateToggle()
      }
    })
  }

  disconnect() {
    this.request?.abort()
    if (this.hasLookupTarget) $(this.lookupTarget).autoComplete('destroy')
  }

  clearSelection() {
    this.request?.abort()
    this.idTarget.value = ''
    this.updateToggle()
  }

  toggleMine() {
    const mine = this.data.get('mine')
    this.idTarget.value = this.idTarget.value === mine ? '' : mine
    if (this.hasLookupTarget) this.lookupTarget.value = this.idTarget.value ? 'My stuff' : ''
    this.updateToggle()
    this.element.requestSubmit()
  }

  updateToggle() {
    const mineSelected = this.idTarget.value === this.data.get('mine')
    this.toggleTarget.setAttribute('aria-pressed', String(mineSelected))
    this.toggleTarget.classList.toggle('active', mineSelected)
  }
}
