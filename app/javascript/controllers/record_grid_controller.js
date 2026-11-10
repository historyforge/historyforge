import { Controller } from 'stimulus'
import AdvancedSearch from '../search/AdvancedSearch'
import * as components from '../js/cell_renderers'
import { gridRequestURL } from '../search/gridRequestURL'

export default class extends Controller {
  connect() {
    this.requests = new AbortController()
    this.url = location.href
    const form = document.getElementById('new_s')
    if (form) {
      new AdvancedSearch(form, this.element.dataset.filtersUrl, JSON.parse(this.element.dataset.filters), this.requests.signal)
    }

    const options = {
      components,
      columnDefs: JSON.parse(this.element.dataset.columns),
      defaultColDef: { width: 100, resizable: true },
      rowSelection: 'single',
      rowModelType: 'infinite',
      datasource: { getRows: params => this.loadRows(params) }
    }
    new window.agGrid.Grid(this.element, options)
    this.api = options.api
  }

  disconnect() {
    this.requests?.abort()
    this.api?.destroy()
    this.api = null
  }

  async loadRows(params) {
    const { signal } = this.requests
    if (signal.aborted) return
    try {
      const response = await fetch(gridRequestURL(this.url, params), {
        headers: { Accept: 'application/json' },
        signal
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      const rows = await response.json()
      if (signal.aborted) return
      const lastRow = rows.length < params.endRow - params.startRow ? params.startRow + rows.length : undefined
      params.successCallback(rows, lastRow)
    } catch (error) {
      if (signal.aborted) return
      console.error('Could not load grid rows', error)
      params.failCallback()
    }
  }
}
