import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.load(`${this.element.dataset.baseUrl}/peeps/${this.element.dataset.year}/1`)
  }

  disconnect() {
    this.request?.abort()
  }

  paginate(event) {
    const link = event.target.closest('.pagination a')
    if (!link) return
    event.preventDefault()
    this.load(link.href)
  }

  async load(url) {
    this.request?.abort()
    const request = new AbortController()
    this.request = request
    try {
      const response = await fetch(url, { signal: request.signal, headers: { Accept: 'text/html' } })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      const html = await response.text()
      if (!request.signal.aborted) this.element.innerHTML = html
    } catch (error) {
      if (!request.signal.aborted) console.error('Could not load census records for term', error)
    }
  }
}
