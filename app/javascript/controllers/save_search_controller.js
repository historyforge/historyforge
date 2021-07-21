import {Controller} from "stimulus";
import SavedSearches from "../js/saved_searches";

export default class extends Controller {
    connect() {
        const url = document.location.toString()
        let what
        if (url.match(/buildings/))
            what = 'building'
        else if (url.match(/census/))
            what = 'census'
        else if (url.match(/people/))
            what = 'people'

        const savedSearchesClass = `${what}SavedSearches`
        window[savedSearchesClass] = window[savedSearchesClass] || new SavedSearches(what)
        this.searches = window[savedSearchesClass]
        this._add = this.add.bind(this)
        this.element.addEventListener('click', this._add)
    }

    disconnect() {
        this.element.removeEventListener('click', this._add)
    }

    add() {
        const params = document.location.search
        this.searches.add(params)
        this.element.blur()
        alertify.log(`Saved search on this browser.`)
    }
}

