$(document).ready(function() {
  $('#search-people-input').each(function() {
    $(this).autoComplete({
      source: function (term, response) {
        $.getJSON(`/search/people?term=${term}`, function (json) {
          return response(json)
        })
      },
      onSelect: function (_event, _term, item) {
        document.location = item.data('url')
      },
      renderItem: function (item) {
        const born = item.year ? `Born ${item.year}` : 'Unknown';
        return `<div class="autocomplete-suggestion" data-url="${item.url}"><div class="float-right">${born}</div>${item.name}</div>`
      },
      delay: 250,
      cache: 0
    })
  })

  $('#search-buildings-input').each(function() {
    $(this).autoComplete({
      source: function (term, response) {
        $.getJSON(`/search/buildings?term=${term}`, function (json) {
          return response(json)
        })
      },
      onSelect: function (event, term, item) {
        document.location = item.data('url')
      },
      renderItem: function (item) {
        return `<div class="autocomplete-suggestion" data-url="${item.url}">${item.name}</div>`
      }
    })
  })
})
