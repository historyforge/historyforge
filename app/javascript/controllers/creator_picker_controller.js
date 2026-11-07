import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['id', 'lookup']

  connect() {
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
      }
    })
  }

  disconnect() {
    this.request?.abort()
    $(this.lookupTarget).autoComplete('destroy')
  }

  clearSelection() {
    this.request?.abort()
    this.idTarget.value = ''
  }
}
