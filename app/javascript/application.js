/* eslint no-console:0 */

import './js/add_child'
import './js/buildings'
import './js/census_form'
import './passkeys'

import '@hotwired/turbo-rails'

import './controllers'
import { loadMaps } from './loadMaps'
import { Notifier } from '@airbrake/browser'

if (window.airbrakeCreds && window.env === 'production') {
  const airbrake = new Notifier({
    projectId: window.airbrakeCreds.app_id,
    projectKey: window.airbrakeCreds.api_key,
    host: window.airbrakeCreds.host,
    environment: 'production'
  })

  window.addEventListener('error', (event) => {
    airbrake.notify({
      error: event.error,
      params: {
        message: event.message,
        filename: event.filename,
        lineno: event.lineno,
        colno: event.colno
      }
    })
  })

  window.addEventListener('unhandledrejection', (event) => {
    airbrake.notify({
      error: event.reason,
      params: {
        promise: event.promise
      }
    })
  })
}

function initializeParallax() {
  document.querySelectorAll('[data-parallax][data-image-src]').forEach(element => {
    element.style.backgroundImage = `url(${JSON.stringify(element.dataset.imageSrc)})`
  })
}

// Ensure textareas and Trix editors maintain resize capability after Turbo navigation
// Turbo's page caching can interfere with native browser resize functionality
const initializeTextareaResize = () => {
  // Handle regular textareas
  const textareas = document.querySelectorAll('textarea');
  textareas.forEach((textarea) => {
    // Ensure resize CSS is applied (may be lost during Turbo navigation)
    if (!textarea.style.resize) {
      textarea.style.resize = 'both';
    }
    // Ensure overflow is set correctly for resize handles to appear
    if (!textarea.style.overflow || textarea.style.overflow === 'hidden') {
      textarea.style.overflow = 'auto';
    }
  });

  // Handle Trix rich text editors (only editable ones, not display versions)
  const trixEditors = document.querySelectorAll('trix-editor');
  trixEditors.forEach((editor) => {
    // Ensure resize CSS is applied to Trix editors
    if (!editor.style.resize) {
      editor.style.resize = 'both';
    }
    if (!editor.style.overflow || editor.style.overflow === 'hidden') {
      editor.style.overflow = 'auto';
    }
    // Ensure minimum height is maintained
    if (!editor.style.minHeight) {
      editor.style.minHeight = '200px';
    }
  });

  // Also handle .trix-content containers, but only when inside forms (editing mode)
  const trixContents = document.querySelectorAll('form .trix-content');
  trixContents.forEach((content) => {
    if (!content.style.resize) {
      content.style.resize = 'both';
    }
    if (!content.style.overflow || content.style.overflow === 'hidden') {
      content.style.overflow = 'auto';
    }
    if (!content.style.minHeight) {
      content.style.minHeight = '200px';
    }
  });
}

// Saved CMS templates can contain these inputs directly instead of using the Rails partials.
function initializeHomeSearch() {
  for (const kind of ['people', 'buildings']) {
    const input = document.getElementById(`search-${kind}-input`)
    if (!input) continue

    input.autocomplete = 'off'
    input.dataset.autocompleteUrl ||= `/search/${kind}`
    input.dataset.autocompleteKind ||= kind
    if (kind === 'people') input.dataset.autocompleteDelay ||= '250'
    const controllers = (input.dataset.controller || '').split(/\s+/).filter(Boolean)
    if (!controllers.includes('autocomplete')) {
      input.dataset.controller = [...controllers, 'autocomplete'].join(' ')
    }
  }
}

// Initialize on both DOMContentLoaded (initial page load) and turbo:load (Turbo navigation)
const initializePage = () => {
  initializeHomeSearch()
  requestAnimationFrame(initializeChangeHistoryTruncation);
  initializeParallax();
  initializeTextareaResize();
}

const initializeMaps = () => {
  if (!document.querySelector('#forge, #miniforge')) return

  loadMaps().then(({ initializeForge, initializeMiniForge }) => {
    initializeForge()
    initializeMiniForge()
  }).catch(error => console.error('Could not initialize maps', error))
}

document.addEventListener('DOMContentLoaded', initializePage)
document.addEventListener('turbo:load', initializePage)
document.addEventListener('DOMContentLoaded', initializeMaps)
document.addEventListener('turbo:load', initializeMaps)

// The header is data-turbo-permanent, so it can show a logged-in menu after the session
// expires. Compare the server-rendered auth state on each page to the header and reload
// when they disagree.
function syncAuthStateWithHeader() {
  const authMeta = document.querySelector('meta[name="hf-auth"]')
  if (!authMeta) return

  const serverSignedIn = authMeta.content === 'signed-in'
  const headerShowsSignedIn = document.querySelector('#main-header #user-menu-item') !== null

  if (serverSignedIn !== headerShowsSignedIn) {
    window.location.reload()
  }
}

document.addEventListener('turbo:load', syncAuthStateWithHeader)

// Update header data (flag counts, login status) - called after login/logout or flag updates
// Update header from incoming Turbo response to avoid flashing
// Since header is permanent (data-turbo-permanent), Turbo won't replace it automatically
// We extract the new header HTML and update only #navbar-nav (the menu list) to preserve everything else
document.addEventListener('turbo:before-render', (event) => {
  try {
    const newDocument = event.detail.newBody;
    if (!newDocument) {
      return
    }

    const newHeader = newDocument.querySelector('#main-header');
    const currentHeader = document.querySelector('#main-header');

    if (newHeader && currentHeader) {
      // Update only the <ul> inside #navbar-nav (the menu list)
      // This preserves the logo, toggle button, and collapse wrapper
      const newNavbarNav = newHeader.querySelector('#navbar-nav');
      const currentNavbarNav = currentHeader.querySelector('#navbar-nav');

      if (newNavbarNav && currentNavbarNav) {
        // Get the ul element inside #navbar-nav
        const newNavList = newNavbarNav.querySelector('ul.navbar-nav');
        const currentNavList = currentNavbarNav.querySelector('ul.navbar-nav');

        if (newNavList && currentNavList) {
          const newNavHTML = newNavList.innerHTML;
          const currentNavHTML = currentNavList.innerHTML;

          // Only update if menu content actually changed
          if (newNavHTML !== currentNavHTML) {
            // Temporarily disable transitions to prevent flash
            currentNavList.style.transition = 'none';

            // Replace only the menu list items (preserves logo, toggle button, collapse wrapper, etc.)
            currentNavList.querySelectorAll('[data-bs-toggle=dropdown]').forEach(element => {
              window.bootstrap.Dropdown.getInstance(element)?.dispose();
            });
            currentNavList.innerHTML = newNavHTML;

            // Re-enable transitions after a brief delay
            setTimeout(() => {
              currentNavList.style.transition = '';
            }, 0);
          }
        }
      }
    }
  } catch (e) {
    // Don't let header update errors prevent page rendering
    console.error('Error updating header in turbo:before-render:', e);
  }
});

// Flag form submissions redirect, so header updates happen automatically via turbo:before-render
// No need for separate AJAX update

// Dynamically load cms.js if user gains CMS permissions after login
// Turbo merges <head> but may not execute new script tags
let cmsScriptLoaded = false;

document.addEventListener('turbo:load', () => {
  const cmsScriptTag = document.head.querySelector('script[src*="cms"]');

  // If cms.js script tag exists but we haven't loaded it yet
  if (cmsScriptTag && !cmsScriptLoaded && !window.initializeCMS) {
    cmsScriptLoaded = true;
    // Script tag exists but hasn't executed - load it manually
    const script = document.createElement('script');
    script.src = cmsScriptTag.src;
    script.type = 'text/javascript';
    script.onload = () => {
      // Trigger CMS initialization if it exists
      if (typeof window.initializeCMS === 'function') {
        window.initializeCMS();
      }
    };
    document.head.appendChild(script);
  } else if (!cmsScriptTag) {
    // Script tag removed (user logged out) - reset flag
    cmsScriptLoaded = false;
  }
});

window.showSubmitButton = function (id, token) {
  const input = document.getElementById(id)
  if (!input) return

  input.value = token
  input.form.querySelector('#contact-submit-btn').style.display = 'block'
}

function addReadMore(texts, target) {
  if (target.nextElementSibling?.matches('.read-more-link')) return
  const needsToggle = texts.some(text => {
    const value = text.textContent.trim()
    return value && value !== 'blank' && (value.length > 50 || text.scrollHeight > text.clientHeight + 10)
  })
  if (!needsToggle) return

  const button = document.createElement('button')
  button.type = 'button'
  button.className = 'read-more-link visible btn btn-sm btn-link p-0'
  button.textContent = 'Read more'
  button.setAttribute('aria-expanded', 'false')
  button.dataset.turboTemporary = ''
  button.addEventListener('click', () => {
    const expanded = !texts[0].classList.contains('expanded')
    texts.forEach(text => text.classList.toggle('expanded', expanded))
    button.textContent = expanded ? 'Read less' : 'Read more'
    button.setAttribute('aria-expanded', String(expanded))
  })
  target.after(button)
}

function initializeChangeHistoryTruncation() {
  for (const row of document.querySelectorAll('.change-history-row')) {
    const pair = [...row.querySelectorAll('.truncate-text[data-row-id]')]
    if (pair.length) addReadMore(pair, row)
    for (const text of row.querySelectorAll('.truncate-text:not([data-row-id])')) addReadMore([text], text)
  }
}

document.addEventListener('turbo:before-cache', () => {
  document.querySelectorAll('.truncate-text.expanded').forEach(text => text.classList.remove('expanded'))
})

document.addEventListener('click', event => {
  event.target.closest('.alert .closer')?.closest('.alert').remove()

  const map = event.target.closest('#search-map')
  if (!map) return
  event.preventDefault()
  const form = map.form
  const params = new URLSearchParams(new FormData(form))
  params.set(map.dataset.year ? 'people' : 'buildings', map.dataset.year || '1')
  window.Turbo.visit('/forge?' + params)
})

const buildingSelector = '#building_id, #census_record_building_id'
let buildingRequest

function updateEnsureBuilding(building) {
  const field = document.querySelector('.census_record_ensure_building')
  if (field) field.hidden = !!building.value
}

async function loadBuildingOptions() {
  buildingRequest?.abort()
  const building = document.querySelector(buildingSelector)
  const street = document.getElementById('street_name')?.value
  const locality = document.getElementById('census_record_locality_id')?.value
  if (!building || !street || !locality) return

  const request = new AbortController()
  buildingRequest = request
  const params = new URLSearchParams({ locality_id: locality, street })
  for (const [name, selector] of Object.entries({
    house: '#census_record_street_house_number, #street_house_number',
    prefix: '#census_record_street_prefix, #street_prefix',
    suffix: '#street_suffix'
  })) {
    const value = document.querySelector(selector)?.value
    if (value) params.set(name, value)
  }
  const year = location.pathname.split('/')[2]
  try {
    const response = await fetch(`/census/${year}/building_autocomplete?${params}`, { signal: request.signal, headers: { Accept: 'application/json' } })
    if (!response.ok) throw new Error(`HTTP ${response.status}`)
    const items = await response.json()
    if (request.signal.aborted || !building.isConnected) return
    const selected = building.value
    building.replaceChildren(new Option('Select a building', ''), ...items.map(item => new Option(item.name, item.id)))
    building.value = items.some(item => String(item.id) === selected) ? selected : ''
    updateEnsureBuilding(building)
  } catch (error) {
    if (!request.signal.aborted) console.error('Could not load building choices', error)
  }
}

const buildingAddressFields = ['house_number', 'street_prefix', 'street_name', 'street_suffix']
let buildingNamed = false
document.addEventListener('turbo:load', () => {
  const building = document.querySelector(buildingSelector)
  if (building) {
    updateEnsureBuilding(building)
    loadBuildingOptions()
  }
  buildingNamed = !!document.getElementById('building_name')?.value
})

document.addEventListener('change', ({ target }) => {
  if (target.matches('#census_record_locality_id, #street_name, #street_suffix, #street_prefix, #street_house_number, #census_record_street_house_number, #census_record_street_prefix')) loadBuildingOptions()
  if (target.matches(buildingSelector)) updateEnsureBuilding(target)
  if (target.id === 'building_name') buildingNamed = !!target.value
  const name = document.getElementById('building_name')
  if (name && !buildingNamed && buildingAddressFields.some(field => target.id === 'building_address_' + field)) {
    name.value = buildingAddressFields.map(field => document.getElementById('building_address_' + field)?.value || '').join(' ')
  }
})

window.addEventListener("trix-file-accept", function (event) {
  event.preventDefault()
  alert("File attachment not supported!")
})
