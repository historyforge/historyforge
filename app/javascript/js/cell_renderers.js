window.GridDataSource = {
  getRows: (options) => {
    const params = {
      from: options.startRow,
      to: options.endRow,
      sort: options.sortModel
    }
    $.getJSON(document.location.toString(), params, (json) => {
      const lastRow = json.length < 100 ? options.startRow + json.length : null
      options.successCallback(json, lastRow)
    })
  }
}

const ActionCellRenderer = function() {}

// gets called once before the renderer is used
ActionCellRenderer.prototype.init = function(params) {
  // create the cell
  this.eGui = document.createElement('div')
  const value = params.value || params.getValue()
  if (value) {
    const link = document.location.toString().split('?')[0] + '/' + (value.id || value)
    this.eGui.innerHTML = `<a href="${link}">View</a>`
  }
}

// gets called once when grid ready to insert the element
ActionCellRenderer.prototype.getGui = function() {
  return this.eGui
}

// gets called whenever the user gets the cell to refresh
ActionCellRenderer.prototype.refresh = function(params) {
  // set value into cell again
  // this.eValue.innerHTML = params.valueFormatted ? params.valueFormatted : params.value;
  // return true to tell the grid we refreshed successfully
  return true
}

const CensusLinkCellRenderer = function() {}

// gets called once before the renderer is used
CensusLinkCellRenderer.prototype.init = function(params) {
  // create the cell
  const value = params.value || params.getValue()
  this.eGui = document.createElement('div')
  if (value) {
    const html = value.id.map(id => `<a href="/census/${value.year}/${id}" target="_blank">View</a>`)
    this.eGui.innerHTML = html.join(" | ")
  }
}

// gets called once when grid ready to insert the element
CensusLinkCellRenderer.prototype.getGui = function() {
  return this.eGui
}

// gets called whenever the user gets the cell to refresh
CensusLinkCellRenderer.prototype.refresh = function(params) {
  // set value into cell again
  // this.eValue.innerHTML = params.valueFormatted ? params.valueFormatted : params.value;
  // return true to tell the grid we refreshed successfully
  return true
}

// gets called when the cell is removed from the grid
CensusLinkCellRenderer.prototype.destroy = function() {}

const NameCellRenderer = function() {}

// gets called once before the renderer is used
NameCellRenderer.prototype.init = function(params) {
  // create the cell
  const value = params.value || params.getValue()
  this.eGui = document.createElement('div')
  if (value && value.name) {
    if (value.id) {
      const link = document.location.toString().split('?')[0] + '/' + (value.id || value)
      this.eGui.innerHTML = `<a href="${link}" title="${value.name}">${value.name}</a>`
    } else {
      this.eGui.innerHTML = value.name
    }

    if (!value.reviewed) {
      this.eGui.innerHTML += '<span class="badge badge-success">NEW</span>'
    }
  } else {
    this.eGui.innerHTML = 'Loading more records.'
  }
}

// gets called once when grid ready to insert the element
NameCellRenderer.prototype.getGui = function() {
  return this.eGui
}

// gets called whenever the user gets the cell to refresh
NameCellRenderer.prototype.refresh = function(params) {
  // set value into cell again
  // this.eValue.innerHTML = params.valueFormatted ? params.valueFormatted : params.value;
  // return true to tell the grid we refreshed successfully
  return true
}

// gets called when the cell is removed from the grid
NameCellRenderer.prototype.destroy = function() {}

const HTMLCellRenderer = function() {}

// gets called once before the renderer is used
HTMLCellRenderer.prototype.init = function(params) {
  const value = params.value || params.getValue()
  this.eGui = document.createElement('div')
  if (value) {
    this.eGui.innerHTML = value
  }
}

// gets called once when grid ready to insert the element
HTMLCellRenderer.prototype.getGui = function() {
  return this.eGui
}

// gets called whenever the user gets the cell to refresh
HTMLCellRenderer.prototype.refresh = function(params) {
  // set value into cell again
  // this.eValue.innerHTML = params.valueFormatted ? params.valueFormatted : params.value;
  // return true to tell the grid we refreshed successfully
  return true
}

// gets called when the cell is removed from the grid
HTMLCellRenderer.prototype.destroy = function() {}

window.ActionCellRenderer = ActionCellRenderer
window.NameCellRenderer = NameCellRenderer
window.CensusLinkCellRenderer = CensusLinkCellRenderer
window.HTMLCellRenderer = HTMLCellRenderer
