import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['predecessor', 'search']

  select({ detail }) {
    const id = String(detail.id)
    const existing = Array.from(this.predecessorTarget.options).find(option => option.value === id)
    if (existing) {
      existing.text = detail.name
    } else {
      this.predecessorTarget.add(new Option(detail.name, id))
    }
    this.predecessorTarget.value = id
    this.searchTarget.value = ''
  }

  clear() {
    this.predecessorTarget.options.length = 1
    this.predecessorTarget.selectedIndex = 0
    this.searchTarget.value = ''
  }
}
