class SavedSearches {
    constructor(thing) {
        this.what = thing
        this.key = `saved_searches_${thing}`
        const rawSearches = window.localStorage.getItem(this.key)
        this.searches = rawSearches ? JSON.parse(rawSearches) : []
    }

    get length() {
        return this.searches.length
    }

    find(name) {
        return this.searches.find(search => search.name === name)
    }

    findIndex(name) {
        return this.searches.findIndex(search => search.name === name)
    }

    add() {
        const name = prompt('Please name this search.')
        if (!name) return

        this.searches.push ({ name, url: document.location.toString() })
        this.save()
    }

    remove(name) {
        const index = this.findIndex(name)
        this.searches.splice(index, 1)
        this.save()
    }

    visit(name) {
        const search = this.find(name)
        document.location = search.url
    }

    forEach(fn) {
        this.searches.forEach(search => fn(search))
    }

    filter(fn) {
        return this.searches.filter(search => fn(search))
    }

    save() {
        window.localStorage.setItem(this.key, JSON.stringify(this.searches))
        window.dispatchEvent(new CustomEvent(`searches:${this.what}`))
    }
}

export default SavedSearches
