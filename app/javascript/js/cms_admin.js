String.prototype.strip = function() { return this.replace(/^\s+/, '').replace(/\s+$/, '') }
String.prototype.toSlug = function() { return this.strip().toLowerCase().replace(/[^-a-z0-9~\s\.:;+=_]/g, '').replace(/[\s\.:;=+]+/g, '-') }

// This section handles the activation of rich text editors and codemirror on the cms page form
$(document).ready(function() {
    $('#cms_page_title').on('change', function() {
        if (('#cms_page_automatic_url_alias').is(':checked'))
            $('#cms_page_url_path').val(this.value.toSlug())
    })
})

// Powers the Save & Edit button
$(document).on('click', '.save-edit', function() { $('#next').val('edit') })
$(document).on('click', '.save-view', function() { $('#next').val('view') })
$(document).on('submit', '#cms-page-form', function() {
    const nextOption = $('#next').val()
    return nextOption && nextOption !== ''
})

$(document).on('click', '#add-picture-button', function(event) { add_cms_page_widget('picture', event) })
$(document).on('click', '#add-embed-button', function(event) { add_cms_page_widget('embed', event) })
$(document).on('click', '#add-audio-button', function(event) { add_cms_page_widget('audio', event) })
$(document).on('click', '#add-document-button', function(event) { add_cms_page_widget('document', event) })
$(document).on('click', '#add-text-button', function(event) { add_cms_page_widget('text', event) })

const add_cms_page_widget = function(widget, event, callback) {
    event.preventDefault()
    event.stopPropagation()
    const name = prompt("What is your administrative name for this #{widget} section?")
    if (name) {
        add_the_cms_widget(widget, name, callback)
        return
    }
    return false
}

const add_the_cms_widget = function(widget, name, callback) {
  const code_name = name.toLowerCase().replace(/\W+/g, '-')

  // create the tab
  const tab_link = $(`<a class="dropdown-item" href="#${code_name}" data-toggle="tab">${name}</a>`)

  // create the form
  let tab_pane = $(`#new_${widget}_fields`).text()
  const new_id = new Date().getTime()
  const regexp = new RegExp("new_widgets", "g")
  tab_pane = $(tab_pane.replace(regexp, new_id))
  tab_pane.find('input.id').remove()
  tab_pane.find('input.human_name').val(name)
  tab_pane.find('input.name').val(code_name)
  tab_pane.find('h3:first').text(name).append("<span class=\"badge badge-danger\">Not Saved</span>")
  tab_pane.attr('id', code_name)

  // add to the dom
  $('.nav-tabs li.nav-item:last .dropdown-menu').append(tab_link)
  $('.tab-pane:last').before(tab_pane)

  // select the tab
  tab_link.tab('show')

  const available_tokens = []
  $('.page-section input.name').each(function() { available_tokens.push("{{#{@value}}}") })
  $('#available-tokens').html(available_tokens.join(', '))

  if (callback) callback(new_id)
}