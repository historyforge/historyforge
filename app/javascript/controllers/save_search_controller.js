import { Controller } from 'stimulus'
import SavedSearches from '../js/saved_searches'

export default class extends Controller {
  add() {
    if (!SavedSearches.for(this.element.dataset.searchKind).add()) return
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
