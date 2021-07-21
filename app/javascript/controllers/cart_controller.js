import {Controller} from "stimulus";

export default class extends Controller {
  connect() {
    this.show()
    this.interval = window.setInterval(() => this.check(), 1000)
  }

  disconnect() {
    window.clearInterval(this.interval)
  }

  empty() {
    window.cart.empty()
  }

  check() {
    const newCount = window.cart.items.length
    if (newCount !== this.count) {
      this.count = newCount
      this.show()
    }
  }

  show() {
    if (window.cart.items.length) {
      const html = `<button type="button" class="btn btn-link dropdown-toggle" data-toggle="dropdown">${this.label}</button>`
        +     `<div class="dropdown-menu">`
        +     `<a class="dropdown-item" href="/cart">View Cart</a>`
        +   `<a class="dropdown-item" href="#" data-action="click->cart#empty">Empty Cart</a>`
        +   `</div>`
      this.element.classList.add('dropdown')
      this.element.innerHTML = html
    } else {
      this.element.classList.remove('dropdown')
      this.element.innerHTML = this.label
    }
    this.count = window.cart.items.length
  }

  get label() {
    const count = window.cart.items.length
    if (count === 0) {
      return 'Cart (empty)'
    }
    if (count === 1) {
      return '1 item in cart'
    }
    return `${count} items in cart`
  }

}