import { Controller } from 'stimulus'
import L from 'leaflet'
import { getMainIcon } from '../forge/mapFunctions'

export default class extends Controller {
  connect() {
    this.addStepNumbers()

    this.paramKey = location.pathname.match(/photographs/) ? 'photograph' : location.pathname.match(/audios/) ? 'audio' : location.pathname.match(/videos/) ? 'video' : 'narrative';
    window.scrollTo(0, 0)

    $('button.btn-prev').on('click', (e) => {
      this.prev(e.target)
    })
    $('button.btn-next').on('click', (e) => {
      this.next(e.target)
    })

    $('#audio_remote_url, #video_remote_url, #photograph_remote_url').on('change', function(e) {
      const value = e.target.value;
      if (value.length) {
        $('.step-1-next-button').removeAttr('disabled')
      } else {
        $('.step-1-next-button').attr('disabled', 'disabled')
      }
    })

    $('#photograph_file').on('change', function () {
      if (this.files.length) {
        const reader = new FileReader()
        reader.onload = function (e) {
          const file = e.target.result
          $('#selected-file, .thumb').html('<img class="img img-thumbnail" alt="" />')
          $('#selected-file img, .thumb img').attr('src', file)
          $('.step-1-next-button').removeAttr('disabled')
        }
        reader.readAsDataURL(this.files[0])
      }
    })

    this.initBuildings()
    this.initPeople()
    this.initDates()
  }

  initDates() {
    $('#dates-question button').on('click', (e) => {
      const type = e.target.dataset.dateType
      $('#dates-question button.btn-primary').removeClass('btn-primary').addClass('btn-light')
      $(e.target).addClass('btn-primary').removeClass('btn-light')
      $('#photograph_date_type').val(type)
      document.getElementById('photograph-date-type').className = type
      $('select:visible').chosen({
        disable_search_threshold: 15
      })
    })
  }

  initPeople() {
    $('#person-question .btn-primary').on('click', function () {
      $('#person-question').fadeOut()
      $('#person-fields').fadeIn()
    })

    let autocompleteTimeout;

    $('#person-autocomplete').on('keyup', (e) => {
      if (e.keyCode === 13) {
        e.stopPropagation()
      }
      const input = e.target
      const value = input.value
      if (value.length > 1) {
        if (autocompleteTimeout) {
          window.clearTimeout(autocompleteTimeout);
        }
        autocompleteTimeout = window.setTimeout(() => {
          $.getJSON('/people/autocomplete', { term: value }, (json) => {
            const people = []
            json.forEach((person) => {
              people.push(`<div class="list-group-item list-group-item-action" data-person=${person.id}>${person.name} (${person.id}) - ${person.years}</div>`)
            })
            $('#person-results').html(people).show()
            $('#person-results .list-group-item').on('click', (e) => {
              const id = e.target.dataset.person
              const name = e.target.innerHTML
              this.addPerson(id, name)
              input.value = null
              $('#person-results').html('')
            })
          })
        }, 500)
      }
    })
  }

  initBuildings() {
    $('#building-question .btn-primary').on('click', function () {
      $('#building-question').fadeOut()
      $('#building-fields').fadeIn()
    })

    $('#building-autocomplete').on('keyup', (e) => {
      if (e.keyCode === 13) {
        e.stopPropagation()
      }
      const input = e.target
      const value = input.value
      if (value.length > 1) {
        $.getJSON('/buildings/autocomplete', { term: value }, (json) => {
          const buildings = []
          json.forEach((building) => {
            buildings.push(`<div class="list-group-item list-group-item-action" data-building=${building.id} data-lat="${building.lat}" data-lon="${building.lon}">${building.address}</div>`)
          })
          $('#building-results').html(buildings).show()
          $('#building-results .list-group-item').on('click', (e) => {
            const id = e.target.dataset.building
            const lat = e.target.dataset.lat
            const lon = e.target.dataset.lon
            const address = e.target.innerHTML
            this.addBuilding(id, address, lat, lon)
            input.value = null
            $('#building-results').html('')
          })
        })
      }
    })
  }

  addBuilding(id, address, lat, lon) {
    const formId = `photograph_building_ids_${id}`
    $(`#${formId}`).closest('.form-check').remove()
    const html = `<div class="form-check"><input type="checkbox" class="form-check-input" name="${this.paramKey}[building_ids][]" id="${formId}" value="${id}" checked /><label class="form-check-label" for="${formId}">${address}</label></div>`
    $(`.${this.paramKey}_building_ids`).append(html)
    if ($(`.${this.paramKey}_building_ids input:checked`).length === 1) {
      $(`#photograph_latitude`).val(lat)
      $(`#photograph_longitude`).val(lon).trigger('change')
    }
  }

  addPerson(id, name) {
    const formId = `${this.paramKey}_person_ids_${id}`
    $(`#person-fields input[value=${id}]`).closest('.form-check').remove()
    const html = `<div class="form-check"><input type="checkbox" class="form-check-input" name="${this.paramKey}[person_ids][]" id="${formId}" value="${id}" checked /><label class="form-check-label" for="${formId}">${name}</label></div>`
    $(`.${this.paramKey}_person_ids`).append(html)
  }

  addStepNumbers() {
    const steps = $('#photo-wizard .card')
    const numSteps = steps.length
    let i = 0
    steps.each(function () {
      $(this).find('.card-body').prepend(`<h3 class="card-title">Step ${++i} of ${numSteps}</h3>`)
    })
  }

  initCard(card) {
    window.scrollTo(0, 0)
    if (card.find('#photograph-map').length && !this.mapInitialized) {
      this.initMap()
    }
    card.find('select:visible').chosen({
      disable_search_threshold: 15
    })
  }

  prev(el) {
    this.initCard($(el).closest('.card').deactivateCard().prev().activateCard())
  }

  next(el) {
    this.initCard($(el).closest('.card').deactivateCard().next().activateCard())
  }

  initMap() {
    this.mapInitialized = true
    const startLat = document.getElementById('photograph_latitude').value
    const startLon = document.getElementById('photograph_longitude').value
    const loc = (startLat && startLon)
      ? [parseFloat(startLat), parseFloat(startLon)]
      : JSON.parse(document.getElementById('photograph-map').dataset.center)

    const map = L.map('photograph-map', {
      center: loc,
      zoom: 13,
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19,
    }).addTo(map)

    const marker = L.marker(loc, {
      icon: getMainIcon(),
      draggable: true,
    }).addTo(map)

    marker.on('dragend', function () {
      const position = marker.getLatLng()
      document.getElementById('photograph_latitude').value = position.lat
      document.getElementById('photograph_longitude').value = position.lng
    })

    $('#photograph_longitude').on('change', function () {
      const lat = document.getElementById('photograph_latitude').value
      const lon = document.getElementById('photograph_longitude').value
      const latlng = L.latLng(parseFloat(lat), parseFloat(lon))
      marker.setLatLng(latlng)
      map.setView(latlng)
    })
  }
}

$.fn.activateCard = function () {
  return this.each(function () {
    $(this).addClass('active')
    return this
  })
}

$.fn.deactivateCard = function () {
  return this.each(function () {
    $(this).removeClass('active')
    return this
  })
}
