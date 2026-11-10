import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    const options = JSON.parse(this.element.dataset.sliderOptions)
    const slides = [...this.element.querySelectorAll('.carousel-inner > :is(.cms-slide, .carousel-item)')]
    if (!slides.length) return
    slides.forEach((slide, index) => {
      if (slide.matches('.carousel-item')) return
      const wrapper = document.createElement('div')
      wrapper.className = index === 0 ? 'carousel-item active' : 'carousel-item'
      slide.before(wrapper)
      wrapper.append(slide)
    })
    if (slides.length < 2) return

    this.controls = []
    this.listeners = new AbortController()
    const { Carousel } = window.bootstrap
    this.element.classList.toggle('carousel-fade', options.animation !== 'slide')
    this.carousel = new Carousel(this.element, {
      interval: Number(options.slideshowSpeed) || 7000,
      pause: options.pauseOnHover === 'true' ? 'hover' : false,
      ride: options.slideshow === 'false' ? false : 'carousel',
      wrap: options.animationLoop !== 'false'
    })
    if (options.controlNav !== 'false') this.addIndicators(slides.length)
    if (options.directionNav === 'false') return

    this.controls.push(...['prev', 'next'].map((direction, index) => {
      const button = document.createElement('button')
      button.type = 'button'
      button.dataset.turboTemporary = ''
      button.className = 'carousel-control-' + direction
      button.setAttribute('aria-label', index === 0 ? 'Previous slide' : 'Next slide')
      const icon = document.createElement('span')
      icon.className = button.className + '-icon'
      icon.setAttribute('aria-hidden', 'true')
      button.append(icon)
      button.addEventListener('click', () => this.carousel[direction]())
      this.element.append(button)
      return button
    }))
  }

  addIndicators(count) {
    const indicators = document.createElement('div')
    indicators.className = 'carousel-indicators'
    indicators.dataset.turboTemporary = ''
    const active = [...this.element.querySelectorAll('.carousel-item')].findIndex(item => item.classList.contains('active'))
    for (let index = 0; index < count; index++) {
      const button = document.createElement('button')
      button.type = 'button'
      button.dataset.bsSlideTo = index
      button.setAttribute('aria-label', 'Slide ' + (index + 1))
      if (index === active) {
        button.classList.add('active')
        button.setAttribute('aria-current', 'true')
      }
      button.addEventListener('click', () => this.carousel.to(index))
      indicators.append(button)
    }
    this.element.prepend(indicators)
    this.controls.push(indicators)

    this.element.addEventListener('slide.bs.carousel', event => {
      const current = indicators.querySelector('[aria-current]')
      current?.classList.remove('active')
      current?.removeAttribute('aria-current')
      indicators.children[event.to].classList.add('active')
      indicators.children[event.to].setAttribute('aria-current', 'true')
    }, { signal: this.listeners.signal })
  }

  disconnect() {
    if (!this.carousel) return
    this.listeners.abort()
    this.carousel.pause()
    this.element.querySelector('.carousel-item.active')?.dispatchEvent(new Event('transitionend'))
    this.carousel.dispose()
    this.carousel = null
    this.controls.forEach(button => button.remove())
  }
}
