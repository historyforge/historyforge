import { Controller } from 'stimulus'
import SavedSearches from '../js/saved_searches'

export default class extends Controller {
  rebuild = () => this.build()

  connect() {
    this.kind = this.element.dataset.searchKind
    this.year = this.element.dataset.searchYear
    this.searches = SavedSearches.for(this.kind)
    this.build()
    window.addEventListener(`searches:${this.kind}`, this.rebuild)
  }

  disconnect() {
    window.removeEventListener(`searches:${this.kind}`, this.rebuild)
  }

  build() {
    const menu = this.element.querySelector('.dropdown-menu')
    const links = []
    this.searches.forEach(search => {
      const url = SavedSearches.urlFor(search)
      if (!url || (this.year && SavedSearches.censusYear(url) !== this.year)) return
      links.push(this.link(search.name, url.href))
    })
    menu.replaceChildren(this.link('Organize Saved Searches', `/searches/saved/${this.kind}`), ...links)
    this.element.hidden = links.length === 0
  }

  link(text, href) {
    const link = document.createElement('a')
    link.className = 'dropdown-item'
    link.href = href
    link.textContent = text
    return link
  }
}
