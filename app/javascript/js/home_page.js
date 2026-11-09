const homeSearchInputs = '#search-people-input, #search-buildings-input'

function initializeHomeSearch(input, endpoint, renderItem, delay) {
  const $input = $(input)
  if ($input.data('sc')) return

  $input.autoComplete({
    source(term, response) {
      if (!isCurrentSearch(term)) return

      $.getJSON(endpoint, { term }, (results) => {
        if (isCurrentSearch(term)) response(results)
      })
    },
    onSelect(_event, _term, item) {
      document.location = item.data('url')
    },
    renderItem,
    delay,
    cache: 0
  })

  const suggestions = $input.data('sc')
  function isCurrentSearch(term) {
    return input.isConnected && input.value === term && $input.data('sc') === suggestions
  }

  // The plugin uses keyup to search, which misses edits such as paste and autofill.
  $input.on('input.homeSearch', () => $input.trigger('keyup.autocomplete'))
}

function initializeHomePageWidgets() {
  $('#search-people-input').each(function () {
    initializeHomeSearch(this, '/search/people', (item) => {
      const born = item.year ? `Born ${item.year}` : 'Unknown'
      return `<div class="autocomplete-suggestion" data-url="${item.url}"><div class="float-right">${born}</div>${item.name}</div>`
    }, 250)
  })

  $('#search-buildings-input').each(function () {
    initializeHomeSearch(this, '/search/buildings', (item) =>
      `<div class="autocomplete-suggestion" data-url="${item.url}">${item.name}</div>`, 150)
  })
}

document.addEventListener('turbo:load', initializeHomePageWidgets)
document.addEventListener('turbo:before-cache', () => {
  $(homeSearchInputs).each(function () {
    const $input = $(this)
    if ($input.data('sc')) $input.off('input.homeSearch').autoComplete('destroy')
  })
})
