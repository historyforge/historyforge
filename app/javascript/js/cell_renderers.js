// Base cell renderer class with common functionality
class BaseCellRenderer {
  init(params) {
    this.eGui = document.createElement('div')
    this.value = params.value || params.getValue()
  }

  getGui() {
    return this.eGui
  }

  refresh() {
    return true
  }

  destroy() { }
}

class ActionCellRenderer extends BaseCellRenderer {
  init(params) {
    super.init(params)
    if (this.value) {
      const baseUrl = document.location.toString().split('?')[0]
      const id = this.value.id || this.value
      this.eGui.innerHTML = `<a href="${baseUrl}/${id}">View</a>`
    }
  }
}

class CensusLinkCellRenderer extends BaseCellRenderer {
  init(params) {
    super.init(params)
    if (this.value) {
      const links = this.value.id.map(id =>
        `<a href="/census/${this.value.year}/${id}" target="_blank">View</a>`
      )
      this.eGui.innerHTML = links.join(" | ")
    }
  }
}

class NameCellRenderer extends BaseCellRenderer {
  init(params) {
    super.init(params)
    if (this.value?.name) {
      if (this.value.id) {
        const baseUrl = document.location.toString().split('?')[0]
        const id = this.value.id || this.value
        const link = document.createElement('a')
        link.href = this.value.href || `${baseUrl}/${encodeURIComponent(id)}`
        link.title = this.value.name
        link.textContent = this.value.name
        this.eGui.append(link)
      } else {
        this.eGui.textContent = this.value.name
      }

      if (!this.value.reviewed) {
        const badge = document.createElement('span')
        badge.className = 'badge badge-success'
        badge.textContent = 'NEW'
        this.eGui.append(badge)
      }
    } else {
      this.eGui.textContent = 'Loading more records.'
    }
  }
}

class HTMLCellRenderer extends BaseCellRenderer {
  init(params) {
    super.init(params)
    if (this.value) {
      this.eGui.innerHTML = this.value
    }
  }
}

export {
  ActionCellRenderer as actionCellRenderer,
  NameCellRenderer as nameCellRenderer,
  CensusLinkCellRenderer as censusLinkCellRenderer,
  HTMLCellRenderer as htmlCellRenderer
}
