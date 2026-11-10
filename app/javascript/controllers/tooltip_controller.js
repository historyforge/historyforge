import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.tooltip = new window.bootstrap.Tooltip(this.element, { animation: false })
  }

  disconnect() {
    this.tooltip?.hide()
    this.tooltip?.dispose()
    this.tooltip = null
  }
}
