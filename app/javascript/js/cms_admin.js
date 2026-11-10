document.addEventListener('change', ({ target }) => {
  if (target.id !== 'cms_page_title' || !document.getElementById('cms_page_automatic_url_alias')?.checked) return
  document.getElementById('cms_page_url_path').value = target.value.trim().toLowerCase()
    .replace(/[^-a-z0-9~\s\.:;+=_]/g, '').replace(/[\s\.:;=+]+/g, '-')
})

document.addEventListener('submit', event => {
  if (event.target.id !== 'cms-page-form') return
  const next = event.target.elements.namedItem('next')
  if (event.submitter?.matches('.save-edit')) next.value = 'edit'
  if (event.submitter?.matches('.save-view')) next.value = 'view'
  if (!next.value) event.preventDefault()
})

document.addEventListener('click', event => {
  const button = event.target.closest('#add-section .dropdown-item')
  if (!button) return
  const widget = button.id.match(/^add-(picture|embed|audio|document|text)-button$/)?.[1]
  if (!widget) return
  event.preventDefault()
  const name = window.prompt(`What is your administrative name for this ${widget} section?`)
  if (name?.trim()) addWidget(widget, name.trim())
})

let widgetSequence = 0
function addWidget(widget, name) {
  const codeName = name.toLowerCase().replace(/\W+/g, '-')
  const id = `new-widget-${++widgetSequence}`
  const template = document.createElement('template')
  template.innerHTML = document.getElementById(`new_${widget}_fields`).textContent.replaceAll('new_widgets', Date.now() + widgetSequence)
  const pane = template.content.querySelector('.tab-pane')
  pane.id = id
  pane.querySelector('input.id')?.remove()
  pane.querySelector('input.human_name').value = name
  pane.querySelector('input.name').value = codeName
  const heading = pane.querySelector('h3')
  const badge = document.createElement('span')
  badge.className = 'badge text-bg-danger ms-2'
  badge.textContent = 'Not Saved'
  heading.replaceChildren(name, badge)
  document.querySelector('#cms-page-form .tab-content').append(pane)

  const tab = document.createElement('a')
  tab.className = 'dropdown-item'
  tab.href = '#' + id
  tab.dataset.bsToggle = 'tab'
  tab.textContent = name
  document.querySelector('#cms-page-form .nav-tabs .dropdown-menu').append(tab)
  window.initializeCMS()
  window.bootstrap.Tab.getOrCreateInstance(tab).show()

  const tokens = document.getElementById('available-tokens')
  if (tokens) {
    tokens.textContent = [...document.querySelectorAll('.page-section input.name')].map(input => '{{' + input.value + '}}').join(', ')
  }
}
