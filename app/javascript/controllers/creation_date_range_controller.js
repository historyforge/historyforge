import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['preset', 'custom']

  connect() {
    this.update()
  }

  update() {
    const custom = this.presetTarget.value === 'custom'
    this.customTarget.hidden = !custom
    this.customTarget.querySelectorAll('input').forEach(input => {
      input.disabled = !custom
    })
  }
}
