import {Controller} from "stimulus";
import SavedSearches from "../js/saved_searches";

export default class extends Controller {
    what = null
    connect() {
        const url = document.location.toString()
        if (url.match(/building/))
            this.what = 'building'
        else if (url.match(/census/))
            this.what = 'census'
        else if (url.match(/people/))
            this.what = 'people'

        const savedSearchesClass = `${this.what}SavedSearches`
        window[savedSearchesClass] = window[savedSearchesClass] || new SavedSearches(this.what)
        this.searches = window[savedSearchesClass]
        this._remove = this.remove.bind(this)
        this.build()

        window.addEventListener(`searches:${this.what}`, () => this.build())
    }

    disconnect() {
        window.removeEventListener(`searches:${this.what}`, () => this.build())
    }

    build() {
        if (!this.searches.length) {
            this.element.innerHTML = "You have no saved searches."
            return
        }

        const menu = document.createElement('UL')
        menu.className = 'list-group'

        this.searches.forEach(({name, url}) => {
            const li = document.createElement("LI")
            li.classList.add('list-group-item')
            const btn = document.createElement('BUTTON')
            btn.className = 'btn btn-sm btn-default close float-right'
            btn.innerHTML = "&times;"
            btn.addEventListener('click', () => this.remove(name))
            li.appendChild(btn)

            const link = document.createElement('A')
            link.href = url
            link.innerHTML = name
            if (this.what === 'census') {
                link.innerHTML += ` (${url.split('/census/')[1].split('?')[0]} US Census)`
            }
            li.appendChild(link)
            menu.appendChild(li)
        })
        this.element.innerHTML = ''
        this.element.appendChild(menu)
    }

    remove(name) {
        this.searches.remove(name)
        this.element.blur()
    }
}

