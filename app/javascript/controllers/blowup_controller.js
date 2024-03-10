import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    if (window.screen.width <= 768) {
      this.element.classList.add('img-fluid')
      return;
    }
    $(this.element).blowup({ scale: 2, cursor: false, width: 300, height: 300 })
  }
}
