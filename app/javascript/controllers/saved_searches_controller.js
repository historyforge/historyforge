import { Controller } from 'stimulus'
import SavedSearches from '../js/saved_searches'

export default class extends Controller {
  rebuild = () => this.build()

  connect() {
    this.kind = this.element.dataset.searchKind
    this.searches = SavedSearches.for(this.kind)
    this.build()
    window.addEventListener(`searches:${this.kind}`, this.rebuild)
  }

  disconnect() {
    window.removeEventListener(`searches:${this.kind}`, this.rebuild)
  }

  build() {
    if (!this.searches.length) {
      this.element.textContent = 'You have no saved searches.'
      return
    }

    const menu = document.createElement('ul')
    menu.className = 'list-group'
    this.searches.forEach(search => {
      const url = SavedSearches.urlFor(search)
      const row = document.createElement('li')
      row.className = 'list-group-item'
      const remove = document.createElement('button')
      remove.type = 'button'
      remove.className = 'btn-close float-end'
      remove.setAttribute('aria-label', 'Remove ' + search.name)
      remove.addEventListener('click', () => this.searches.remove(search.name))

      const label = document.createElement(url ? 'a' : 'span')
      if (url) label.href = url.href
      const year = this.kind === 'census' && url && SavedSearches.censusYear(url)
      label.textContent = year ? `${search.name} (${year} US Census)` : search.name
      row.append(remove, label)
      menu.append(row)
    })
    this.element.replaceChildren(menu)
  }
}
