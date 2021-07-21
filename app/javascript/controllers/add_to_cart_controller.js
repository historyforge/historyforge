import {Controller} from "stimulus";

export default class extends Controller {
  connect() {
    this.element.addEventListener('click', (e) => this.add(e));
  }
  add(e) {
    const id = parseInt(this.element.dataset.cartAdd || this.element.parentNode.dataset.productId)
    window.cart.addItem(id)
    e.preventDefault();
    e.stopPropagation();
    return false;
  }
}
