import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.element.addEventListener('focus', this.createAutoComplete)
  }

  disconnect() {
    this.element.removeEventListener('focus', this.createAutoComplete)
  }

  _createAutoComplete() {
    const tempBU = $('#bulk_update_field').val()
    const isBulkUpdate = tempBU && tempBU.length

    const attributeName = isBulkUpdate ? tempBU : this.element.getAttribute('name').match(/census_record\[(\w+)]/)[1]
    const urlParts = document.location.pathname.split('/')
    const url = `/census/${urlParts[2]}/autocomplete?attribute=${attributeName}`

    $(this.element).autoComplete({
      source: function(term, response) {
        $.getJSON(url, { term }, function(json) { response(json) })
      },
      onSelect: () => $(this.element).trigger('click')
    })
  }

    createAutoComplete = this._createAutoComplete.bind(this)
}
