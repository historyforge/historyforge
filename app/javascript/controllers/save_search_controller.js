import { Controller } from 'stimulus'
import SavedSearches from '../js/saved_searches'

export default class extends Controller {
  connect() {
    const url = document.location.toString()
    let what
    if (url.match(/buildings/)) { what = 'building' } else if (url.match(/census/)) { what = 'census' } else if (url.match(/people/)) { what = 'people' }

    const savedSearchesClass = `${what}SavedSearches`
    window[savedSearchesClass] = window[savedSearchesClass] || new SavedSearches(what)
    this.searches = window[savedSearchesClass]
    this._add = this.add.bind(this)
    this.element.addEventListener('click', this._add)
  }

  disconnect() {
    this.element.removeEventListener('click', this._add)
  }

  add() {
    if (!this.searches.add()) return
    this.element.blur()
    const alerts = document.getElementById('alerts')
    if (!alerts) return

    alerts.querySelector('[data-saved-search-notice]')?.remove()
    const notice = document.createElement('div')
    notice.className = 'alert alert-success alert-dismissible'
    notice.dataset.savedSearchNotice = ''
    notice.dataset.turboTemporary = ''
    notice.setAttribute('role', 'status')
    notice.textContent = 'Saved search on this browser.'
    const close = document.createElement('button')
    close.type = 'button'
    close.className = 'btn-close'
    close.dataset.bsDismiss = 'alert'
    close.setAttribute('aria-label', 'Close')
    notice.append(close)
    alerts.append(notice)
  }
}
