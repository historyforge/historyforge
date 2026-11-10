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
        this.eGui.innerHTML = `<a href="${baseUrl}/${id}" title="${this.value.name}">${this.value.name}</a>`
      } else {
        this.eGui.innerHTML = this.value.name
      }

      if (!this.value.reviewed) {
        this.eGui.innerHTML += '<span class="badge badge-success">NEW</span>'
      }
    } else {
      this.eGui.innerHTML = 'Loading more records.'
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
