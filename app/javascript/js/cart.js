class Cart {
  constructor() {
    this.load()
  }

  addItem(id) {
    if (!this.contains(id)) {
      this.items.push(id)
      this.save()
    }
    window.alertify.success("Added to cart!")
  }

  addAll() {
    const url = document.location.origin + document.location.pathname
    const data = jq('#new_q').serializeArray()
    data.push({name: 'page', value: 'all'})
    $.ajax({
      url,
      data,
      dataType: 'json',
      success: (json) => {
        const ids = json.map(product => product.id)
        this.addItems(ids)
        window.alertify.success(`Added ${json.length} items to cart!`)
      }
    })
  }

  addItems(ids) {
    ids.forEach(id => {
      if (!this.contains(id)) {
        this.items.push(id)
      }
    })
    this.save()
  }

  removeItem(id) {
    const index = this.items.indexOf(id)
    this.items.splice(index, 1)
    this.save()
  }

  load() {
    const raw = window.localStorage.getItem('photo-cart')
    this.items = raw && raw.length ? JSON.parse(raw) : []
  }

  save() {
    window.localStorage.setItem('photo-cart', JSON.stringify(this.items))
  }

  empty() {
    this.items = []
    window.localStorage.removeItem('photo-cart')
    window.alertify.success("Cart emptied!")
    $('#cart-contents').html(null)
  }

  contains(id) {
    return this.items.indexOf(id) !== -1
  }
}

export default Cart;