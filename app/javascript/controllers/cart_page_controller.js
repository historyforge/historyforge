import {Controller} from "stimulus";

export default class extends Controller {
  connect() {
    $.ajax({
      url: '/cart/fetch',
      data: { ids: window.cart.items },
      dataType: 'json',
      method: 'post',
      success: (json) => {
        $('#cart-contents').empty()
        $('.cart-export-params').empty()
        json.forEach(item => {
          const photo = item.photo ? `<img src="${item.photo}" />` : 'No photo'
          const removeBtn = "<button class='btn btn-text' type=\"button\" data-photograph-id=\"${item.id}\" data-action='click->cart-page#remove' rel='tooltip' data-title='Remove from Cart'><i class='fa fa-minus-circle' /></button>"
          const row = `<tr><td>${photo}</td><td>${item.title || 'Untitled'}<br />${item.description || 'No description'}</td><td>${removeBtn}</td></tr>`
          $('#cart-contents').append(row)

          const input = `<input type="hidden" name="ids[]" value="${item.id}" />`
          $('#cart-export-params').append(input)
        })
        $('#cart-contents [rel="tooltip"]').tooltip()
      }
    })
  }

  disconnect() {
  }

  remove(e) {
    e.preventDefault()
    const id = parseInt(e.target.dataset.photographId)
    window.cart.removeItem(id)
    $(e.target).closest('tr').remove()
  }
}