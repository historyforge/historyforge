/* eslint no-console:0 */
import 'chartkick/chart.js'
import '../../vendor/assets/javascripts/parallax.min'
import '../../vendor/assets/javascripts/jquery.mousewheel'
import '../../vendor/assets/javascripts/chosen.jquery'
import '../../vendor/assets/javascripts/blowup'

import './js/add_child'
import './js/buildings'
import './js/cell_renderers'
import './search/AdvancedSearch'
import './js/census_form'
import './js/home_page'
import './js/terms'
import './passkeys'

import '@hotwired/turbo-rails'

import './controllers'
import './forge'
import './miniforge'
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

// Initialize parallax on elements with data-parallax attribute
const initializeParallax = () => {
  const $ = window.jQuery || window.$;
  if (!$ || !$.fn.parallax) return;

  // Destroy existing parallax instances first to avoid duplicates
  $('[data-parallax]').each(function () {
    const $el = $(this);
    // Check if parallax is already initialized
    if ($el.data('px.parallax')) {
      $el.parallax('destroy');
    }
    // Reinitialize parallax
    $el.parallax();
  });

  // Trigger resize/scroll to refresh parallax positions
  $(window).trigger('resize').trigger('scroll');
};

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

// Initialize on both DOMContentLoaded (initial page load) and turbo:load (Turbo navigation)
const initializePage = () => {
  pageLoad();
  initializeParallax();
  initializeTextareaResize();
}

// Cleanup before Turbo caches the page
const cleanupPage = () => {
  const $ = window.jQuery || window.$;
  // Destroy Bootstrap tooltips to prevent memory leaks
  $('[rel=tooltip]').tooltip('dispose');
  // Destroy parallax instances to prevent memory leaks
  if ($ && $.fn.parallax) {
    $('[data-parallax]').each(function () {
      const $el = $(this);
      if ($el.data('px.parallax')) {
        $el.parallax('destroy');
      }
    });
  }
}

document.addEventListener('DOMContentLoaded', initializePage)
document.addEventListener('turbo:load', initializePage)
document.addEventListener('turbo:before-cache', cleanupPage)

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
            currentNavList.innerHTML = newNavHTML;

            // Re-enable transitions after a brief delay
            setTimeout(() => {
              currentNavList.style.transition = '';
            }, 0);

            // Re-initialize Bootstrap dropdowns
            // Use setTimeout to ensure DOM is ready
            setTimeout(() => {
              const $ = window.jQuery || window.$;
              if ($ && typeof $.fn.dropdown !== 'undefined') {
                $('#main-header [data-toggle="dropdown"]').each(function () {
                  const $toggle = $(this);
                  try {
                    const dropdownData = $toggle.data('bs.dropdown');
                    if (dropdownData) {
                      dropdownData.dispose();
                    }
                  } catch (e) {
                    // No existing instance
                  }
                  try {
                    $toggle.dropdown();
                  } catch (e) {
                    // Bootstrap will handle via delegation
                  }
                });
              }
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
  if (cmsScriptTag && !cmsScriptLoaded) {
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
  document.getElementById(id).setAttribute('value', token);
  document.getElementById('contact-submit-btn').style.display = 'block'
}

const pageLoad = function () {
  $('[rel=tooltip]').tooltip()
  initializeChangeHistoryTruncation()
}

// Initialize change history text truncation with read more/less
function initializeChangeHistoryTruncation() {
  const $ = window.jQuery || window.$
  if (!$) return

  // Use setTimeout to ensure styles are applied and DOM is ready
  setTimeout(function () {
    // Process each wrapper individually
    $('.change-history-row-wrapper').each(function () {
      const $wrapper = $(this)
      const $row = $wrapper.find('.change-history-row')

      // Skip if already has a read more link
      if ($wrapper.find('.read-more-link').length) {
        return
      }

      // Find all truncate-text elements with data-row-id in this row
      const $texts = $row.find('.truncate-text[data-row-id]')

      if ($texts.length === 0) {
        return
      }

      const rowId = $texts.first().data('row-id')
      let isAnyTruncated = false

      // Check each text element
      $texts.each(function () {
        const $text = $(this)
        const textContent = $text.text().trim()

        // Skip if no meaningful content
        if (!textContent || textContent === 'blank') {
          return
        }

        // Simple check: if text is longer than 50 characters, assume it might be truncated
        // This is a reliable fallback (roughly 2 lines at typical column width)
        if (textContent.length > 50) {
          isAnyTruncated = true
          return false // break
        }

        // Also check height-based truncation
        const constrainedHeight = $text[0].clientHeight

        // Temporarily remove constraints
        const originalStyles = {
          display: $text.css('display'),
          webkitLineClamp: $text.css('-webkit-line-clamp'),
          maxHeight: $text.css('max-height'),
          overflow: $text.css('overflow'),
          webkitBoxOrient: $text.css('-webkit-box-orient')
        }

        $text.css({
          'display': 'block',
          '-webkit-line-clamp': 'unset',
          '-webkit-box-orient': 'unset',
          'max-height': 'none',
          'overflow': 'visible'
        })

        $text[0].offsetHeight // Force reflow

        const fullHeight = $text[0].scrollHeight

        // Restore styles
        $text.css(originalStyles)

        // Check if truncated
        if (fullHeight > constrainedHeight + 10) {
          isAnyTruncated = true
          return false // break
        }
      })

      // Add link if any field is truncated
      if (isAnyTruncated) {
        const $link = $('<a>', {
          href: '#',
          class: 'read-more-link visible btn btn-sm btn-link p-0',
          'data-row-id': rowId,
          text: 'Read more'
        })
        const $linkRow = $('<div>', { class: 'row mt-2' })
        const $linkCol = $('<div>', { class: 'col-12' })
        $linkCol.append($link)
        $linkRow.append($linkCol)
        $row.after($linkRow)
      }
    })

    // Handle "create" events separately (single value field)
    $('.change-history-row .truncate-text:not([data-row-id])').each(function () {
      const $text = $(this)
      const changeId = $text.data('change-id')
      const textContent = $text.text().trim()

      // Skip if no content or already has a read more link
      if (!textContent || textContent === 'blank' || $text.next('.read-more-link').length) {
        return
      }

      // Get the current constrained height (with line-clamp applied)
      const constrainedHeight = $text[0].clientHeight

      // Temporarily remove line-clamp to measure full content height
      const originalDisplay = $text.css('display')
      const originalLineClamp = $text.css('-webkit-line-clamp')
      const originalMaxHeight = $text.css('max-height')
      const originalOverflow = $text.css('overflow')

      // Remove constraints temporarily
      $text.css({
        'display': 'block',
        '-webkit-line-clamp': 'unset',
        'max-height': 'none',
        'overflow': 'visible'
      })

      // Measure the full height without constraints
      const fullHeight = $text[0].scrollHeight

      // Restore original styles
      $text.css({
        'display': originalDisplay,
        '-webkit-line-clamp': originalLineClamp,
        'max-height': originalMaxHeight,
        'overflow': originalOverflow
      })

      // If full height is greater than constrained height, text is truncated
      // Use 10px tolerance for browser rendering differences
      const isTruncated = fullHeight > constrainedHeight + 10

      if (isTruncated) {
        const $link = $('<a>', {
          href: '#',
          class: 'read-more-link visible btn btn-sm btn-link p-0',
          'data-change-id': changeId,
          text: 'Read more'
        })
        $text.after($link)
      }
    })
  }, 200)
}

// Handle "Read more" / "Read less" toggle for change history text
jQuery(document).on('click', '.read-more-link', function (e) {
  e.preventDefault()
  const $link = $(this)
  const rowId = $link.data('row-id')
  const changeId = $link.data('change-id')

  if (rowId) {
    // Handle "from" and "to" fields together
    const $texts = $('.truncate-text[data-row-id="' + rowId + '"]')

    if ($texts.length === 0) {
      console.error('Could not find text elements with row-id:', rowId)
      return
    }

    const isExpanded = $texts.first().hasClass('expanded')

    if (isExpanded) {
      $texts.removeClass('expanded')
      $link.text('Read more')
    } else {
      $texts.addClass('expanded')
      $link.text('Read less')
    }
  } else if (changeId) {
    // Handle single field (create events)
    const $text = $('.truncate-text[data-change-id="' + changeId + '"]')

    if ($text.length === 0) {
      console.error('Could not find text element with change-id:', changeId)
      return
    }

    if ($text.hasClass('expanded')) {
      $text.removeClass('expanded')
      $link.text('Read more')
    } else {
      $text.addClass('expanded')
      $link.text('Read less')
    }
  }
})

jQuery(document).on('click', '.alert .closer', function () {
  jQuery(this).closest('.alert').remove();
  jQuery(window).trigger('resize').trigger('scroll'); // trigger parallax refresh on home page
});
jQuery(document).on('click', '.dropdown-item.checkbox', function (e) { e.stopPropagation() })

// Fix for AdvancedRestoreSearch with Turbo
// The server-side AdvancedRestoreSearch concern saves field selections and redirects to restore them,
// but Turbo's page cache can restore pages without hitting the server, bypassing the redirect.
// Instead of forcing a visit (which causes white screen issues), we'll rely on cache prevention
// and let the server-side redirect happen naturally when the page is actually visited.
// The cache prevention below ensures index pages always hit the server.

// Prevent Turbo from caching index pages (people, buildings, census records)
// Index pages show lists that can change when new records are created, so they should
// always fetch fresh data from the server instead of using cached versions.
// We use data-turbo-cache="false" on the body tag to prevent caching.
if (typeof Turbo !== 'undefined') {
  document.addEventListener('turbo:before-cache', function (event) {
    // Check if this is an index page with a grid
    const hasGrid = document.querySelector('#grid') !== null
    if (hasGrid) {
      // Prevent this page from being cached
      // This ensures that when users navigate back to index pages, they get fresh data
      const currentUrl = window.location.href
      try {
        // Remove this specific page from cache
        if (Turbo.cache && typeof Turbo.cache.remove === 'function') {
          Turbo.cache.remove(currentUrl)
        }
      } catch (e) {
        // Cache API might not be available in all Turbo versions - ignore
        console.debug('Could not remove page from Turbo cache:', e)
      }
    }
  })
}

jQuery(document).on('click', '#search-map', function () {
  const $form = jQuery(this).closest('form')
  if (document.location.toString().match(/building/)) {
    $form.append('<input type="hidden" name="buildings" value="1">')
  } else {
    const year = jQuery(this).data('year')
    $form.append(`<input type="hidden" name="people" value="${year}">`)
  }
  $form.attr('action', '/forge')
  $form.submit()
})

function getBuildingList() {
  let house = $('#census_record_street_house_number').val()
  if (house === '') house = null
  let locality_id = jQuery('#census_record_locality_id').val()
  let street = jQuery('#street_name').val()
  if (street === '') street = null
  let prefix = jQuery('#census_record_street_prefix').val()
  if (street === '') prefix = null
  let suffix = jQuery('#street_suffix').val()
  if (street === '') suffix = null
  if (locality_id && street) {
    const params = { locality_id, street, prefix, suffix, house }
    const year = document.location.pathname.split("/")[2]
    jQuery.getJSON(`/census/${year}/building_autocomplete`, params, function (json) {
      const building = jQuery('#building_id, #census_record_building_id')
      const current_value = building.val()
      let html = '<option value="">Select a building</option>'
      json.forEach(function (item) {
        html += `<option value="${item.id}">${item.name}</option>`
      })
      building.html(html)
      building.val(current_value)
      $('.census_record_ensure_building').toggle(!building.val().length)
    })
  }
}
// When the user fills address on census form, this refills the building_id dropdown
jQuery(document)
  .on('change', '#census_record_locality_id, #street_name, #street_suffix, #street_prefix, #street_house_number', getBuildingList)

const initializeBuildingFields = () => {
  const building = jQuery('#building_id, #census_record_building_id')
  if (building.length) {
    getBuildingList()
    $('.census_record_ensure_building').toggle(!building.val().length)
  }
}

jQuery(document)
  .on('turbo:load', initializeBuildingFields)
  .on('change', '#building_id, #census_record_building_id', function () {
    $('.census_record_ensure_building').toggle(!$(this).val().length)
  })

let buildingNamed = false
const initializeBuildingName = () => {
  buildingNamed = jQuery('#building_name').val()
}
jQuery(document).on('turbo:load', initializeBuildingName)

jQuery(document).on('change', '#building_address_house_number, #building_address_street_prefix, #building_address_street_name, #building_address_street_suffix', function () {
  if (buildingNamed) return
  const buildingName = [jQuery('#building_address_house_number').val(), jQuery('#building_address_street_prefix').val(), jQuery('#building_address_street_name').val(), jQuery('#building_address_street_suffix').val()].join(' ')
  jQuery('#building_name').val(buildingName)
})

window.addEventListener("trix-file-accept", function (event) {
  event.preventDefault()
  alert("File attachment not supported!")
})
