import {Controller} from "stimulus";

export default class extends Controller {
    connect() {
        const attribute_name = this.element.dataset.attribute
        const urlParts = document.location.pathname.split('/');
        const url = `/census/${urlParts[2]}/autocomplete?attribute=${attribute_name}`
        $(this.element).autoComplete({
            source: function(term, response) {
                $.getJSON(url, { term }, function(json) {
                    response(json)
                })
            },
            // onSelect: () => $(this).trigger('click')
        })
    }
    disconnect() {
        $(this.element).autoComplete('destroy')
    }
}
