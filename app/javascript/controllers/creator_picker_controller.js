import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['id', 'submit']

  select(event) {
    this.idTarget.value = event.detail.id
    if (this.hasSubmitTarget) this.submitTarget.disabled = false
  }

  clearSelection() {
    this.idTarget.value = ''
    if (this.hasSubmitTarget) this.submitTarget.disabled = true
  }
}
