import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['id']

  select(event) {
    this.idTarget.value = event.detail.id
  }

  clearSelection() {
    this.idTarget.value = ''
  }
}
