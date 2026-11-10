import { Controller } from 'stimulus'

let nextListId = 0

export default class extends Controller {
  connect() {
    this.list = document.createElement('div')
    this.list.id = `autocomplete-${++nextListId}`
    this.list.className = 'autocomplete-suggestions'
    this.list.setAttribute('role', 'listbox')
    this.list.hidden = true
    document.body.append(this.list)

    this.element.setAttribute('role', 'combobox')
    this.element.setAttribute('aria-autocomplete', 'list')
    this.element.setAttribute('aria-controls', this.list.id)
    this.element.setAttribute('aria-expanded', 'false')

    this.listeners = new AbortController()
    const options = { signal: this.listeners.signal }
    this.element.addEventListener('input', event => this.search(event), options)
    this.element.addEventListener('compositionend', event => this.search(event), options)
    this.element.addEventListener('keydown', event => this.keydown(event), options)
    this.element.addEventListener('blur', () => this.close(), options)
    this.list.addEventListener('pointerdown', event => event.preventDefault(), options)
    this.list.addEventListener('click', event => {
      const option = event.target.closest('[role=option]')
      if (option) this.select(this.items[Number(option.dataset.index)])
    }, options)
    window.addEventListener('resize', () => this.position(), options)
    window.addEventListener('scroll', () => this.position(), { ...options, capture: true })
    document.addEventListener('turbo:before-cache', () => this.disconnect(), options)
  }

  disconnect() {
    if (!this.list) return
    this.close()
    this.listeners.abort()
    this.list.remove()
    this.list = null
    for (const attribute of ['role', 'aria-autocomplete', 'aria-controls', 'aria-expanded']) {
      this.element.removeAttribute(attribute)
    }
  }

  close() {
    clearTimeout(this.timer)
    this.request?.abort()
    this.list.hidden = true
    this.list.replaceChildren()
    this.element.setAttribute('aria-expanded', 'false')
    this.element.removeAttribute('aria-activedescendant')
    this.active = -1
  }

  search(event) {
    this.close()
    const term = this.element.value
    const { autocompleteMin = 3, autocompleteDelay = 150 } = this.element.dataset
    if (event.isComposing || term.length < Number(autocompleteMin)) return
    this.timer = setTimeout(() => this.load(term), Number(autocompleteDelay))
  }

  async load(term) {
    const request = new AbortController()
    this.request = request
    const url = new URL(this.element.dataset.autocompleteUrl, document.baseURI)
    url.searchParams.set('term', term)
    try {
      const response = await fetch(url, { signal: request.signal, headers: { Accept: 'application/json' } })
      if (!response.ok) return
      const items = await response.json()
      if (request.signal.aborted || this.element.value !== term || document.activeElement !== this.element) return
      this.render(items)
    } catch (error) {
      if (!request.signal.aborted) console.error('Autocomplete request failed', error)
    }
  }

  render(items) {
    this.items = items
    items.forEach((item, index) => {
      const option = document.createElement('div')
      option.className = 'autocomplete-suggestion'
      option.id = `${this.list.id}-${index}`
      option.dataset.index = index
      option.setAttribute('role', 'option')
      option.setAttribute('aria-selected', 'false')
      option.textContent = typeof item === 'string' ? item : item.name
      if (this.element.dataset.autocompleteKind === 'people') {
        const year = document.createElement('span')
        year.className = 'float-end ms-2'
        year.textContent = item.year ? `Born ${item.year}` : 'Unknown'
        option.prepend(year)
      }
      if (this.element.dataset.autocompleteKind === 'creator') {
        option.textContent += item.name === item.login ? ` · #${item.id}` : ` (${item.login}) · #${item.id}`
      }
      this.list.append(option)
    })
    this.list.hidden = items.length === 0
    this.element.setAttribute('aria-expanded', String(!this.list.hidden))
    this.position()
  }

  position() {
    if (this.list.hidden) return
    const { left, bottom, width } = this.element.getBoundingClientRect()
    Object.assign(this.list.style, { left: `${left}px`, top: `${bottom}px`, width: `${width}px` })
  }

  keydown(event) {
    if (event.isComposing) return
    if (event.key === 'Escape' && !this.list.hidden) {
      event.preventDefault()
      this.close()
    }
    if (this.list.hidden) return

    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault()
      this.list.children[this.active]?.setAttribute('aria-selected', 'false')
      const last = this.items.length - 1
      this.active = event.key === 'ArrowDown'
        ? (this.active + 1) % this.items.length
        : (this.active <= 0 ? last : this.active - 1)
      const option = this.list.children[this.active]
      option.setAttribute('aria-selected', 'true')
      this.element.setAttribute('aria-activedescendant', option.id)
      option.scrollIntoView({ block: 'nearest' })
    } else if (this.active >= 0 && (event.key === 'Enter' || event.key === 'Tab')) {
      if (event.key === 'Enter') event.preventDefault()
      this.select(this.items[this.active])
    }
  }

  select(item) {
    this.close()
    if (item.url) {
      window.Turbo.visit(item.url)
      return
    }

    this.element.value = typeof item === 'string' ? item : item.name
    this.element.dispatchEvent(new Event('change', { bubbles: true }))
    if (typeof item === 'string') this.element.click()
    this.element.dispatchEvent(new CustomEvent('autocomplete:selected', { bubbles: true, detail: item }))
  }
}
