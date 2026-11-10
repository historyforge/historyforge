import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.element.classList.add('img-fluid')
    if (!window.matchMedia('(min-width: 769px) and (hover: hover) and (pointer: fine)').matches) return

    this.listeners = new AbortController()
    const options = { signal: this.listeners.signal }
    this.lens = document.createElement('div')
    this.lens.className = 'photo-zoom-lens'
    this.lens.dataset.turboTemporary = ''
    this.lens.hidden = true
    document.body.append(this.lens)
    this.element.addEventListener('pointermove', event => this.zoom(event), options)
    this.element.addEventListener('pointerleave', () => { this.lens.hidden = true }, options)
  }

  zoom({ clientX, clientY }) {
    const { left, top, width, height } = this.element.getBoundingClientRect()
    const radius = 150
    Object.assign(this.lens.style, {
      left: `${clientX - radius}px`,
      top: `${clientY - radius}px`,
      backgroundImage: `url(${JSON.stringify(this.element.currentSrc)})`,
      backgroundSize: `${width * 2}px ${height * 2}px`,
      backgroundPosition: `${radius - (clientX - left) * 2}px ${radius - (clientY - top) * 2}px`
    })
    this.lens.hidden = false
  }

  disconnect() {
    this.listeners?.abort()
    this.lens?.remove()
  }
}
