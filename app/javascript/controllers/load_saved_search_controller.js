import {Controller} from "stimulus";
import SavedSearches from "../js/saved_searches";

export default class extends Controller {
    what = null
    connect() {
        const url = document.location.toString()
        if (url.match(/buildings/))
            this.what = 'building'
        else if (url.match(/census/))
            this.what = 'census'
        else if (url.match(/people/))
            this.what = 'people'

        const savedSearchesClass = `${this.what}SavedSearches`
        window[savedSearchesClass] = window[savedSearchesClass] || new SavedSearches(this.what)
        this.searches = window[savedSearchesClass]
        this.build()

        window.addEventListener(`searches:${this.what}`, () => this.build())
    }

    disconnect() {
        window.removeEventListener(`searches:${this.what}`, () => this.build())
    }

    build() {
        let searches

        if (this.what === 'census') {
            const year = document.location.toString().split('/census/')[1].split('?')[0]
            searches = this.searches.filter(search => search.url.match(`census/${year}`))
        } else {
            searches = this.searches
        }

        if (!searches.length) {
            this.element.style.display = 'none'
            return
        }

        const menu = this.element.querySelector('.dropdown-menu')
        menu.innerHTML = `<a class="dropdown-item" href="/searches/saved/${this.what}">Organize Saved Searches</a>`

        searches.forEach(({ name, url }) => {
            const html = `<a class="dropdown-item" href="${url}">${name}</a>`
            menu.innerHTML += html
        })

        this.element.style.display = 'inline-block'
    }
}

