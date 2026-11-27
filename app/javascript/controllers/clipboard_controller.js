import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['source', 'status']

  async copyLink(event) {
    event.preventDefault()
    const url = event.currentTarget.href
    try {
      await navigator.clipboard.writeText(url)
      this.statusTarget.textContent = 'Summary link copied.'
    } catch {
      window.prompt('Copy this summary link:', url)
    }
  }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.sourceTarget.value)
      this.statusTarget.textContent = 'Prompt copied.'
    } catch {
      this.sourceTarget.focus()
      this.sourceTarget.select()
      this.statusTarget.textContent = 'Prompt selected. Use your keyboard to copy it.'
    }
  }
}
