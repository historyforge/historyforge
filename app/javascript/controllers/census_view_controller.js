import { Controller } from 'stimulus'

const preferenceKey = 'historyforge.person-census-view'

export default class extends Controller {
  static targets = ['controls', 'cards', 'table', 'cardsButton', 'tableButton']

  connect() {
    let showTable = false
    try {
      showTable = window.localStorage.getItem(preferenceKey) === 'table'
    } catch {
      // The view still works when browser storage is unavailable.
    }
    this.renderView(showTable)
    this.controlsTarget.classList.remove('d-none')
  }

  showCards() {
    this.selectView(false)
  }

  showTable() {
    this.selectView(true)
  }

  selectView(showTable) {
    this.renderView(showTable)
    try {
      window.localStorage.setItem(preferenceKey, showTable ? 'table' : 'cards')
    } catch {
      // Keep the selection for this page when it cannot be saved.
    }
  }

  renderView(showTable) {
    this.cardsTarget.hidden = showTable
    this.tableTarget.hidden = !showTable
    this.cardsButtonTarget.classList.toggle('active', !showTable)
    this.tableButtonTarget.classList.toggle('active', showTable)
    this.cardsButtonTarget.setAttribute('aria-pressed', String(!showTable))
    this.tableButtonTarget.setAttribute('aria-pressed', String(showTable))
  }
}
