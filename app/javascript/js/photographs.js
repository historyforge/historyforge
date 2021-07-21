$(document).ready(function () {
    $('#photo-wizard').each(function () {
        new PhotoWizard()
    })
    $('#photograph').each(function () {
        new PhotoPage()
    })
})

class PhotoPage {
    constructor() {
        $('#photograph').blowup({scale: 2, cursor: false, width: 300, height: 300})
    }
}

class PhotoWizard {
    constructor() {
        this.addStepNumbers()

        window.scrollTo(0, 0)

        $('button.btn-prev').on('click', (e) => {
            this.prev(e.target)
        })
        $('button.btn-next').on('click', (e) => {
            this.next(e.target)
        })
        $('#physical-formats .list-group-item').on('click', (e) => this.selectFormat(e.target))
        $('#rights-statements .list-group-item').on('click', (e) => this.selectStatement(e.target))

        $('#photograph_file').on('change', function () {
            if (this.files.length) {
                const reader = new FileReader()
                reader.onload = function (e) {
                    const file = e.target.result
                    $('#selected-file, .thumb').html(`<img class="img img-thumbnail" alt="" />`)
                    $('#selected-file img, .thumb img').attr('src', file)
                    $('.step-1-next-button').removeAttr('disabled')
                }
                reader.readAsDataURL(this.files[0])
            }
        })

        this.initBuildings()
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
                $.getJSON('/buildings/autocomplete', {term: value}, (json) => {
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
        const html = `<div class="form-check"><input type="checkbox" class="form-check-input" name="photograph[building_ids][]" id="${formId}" value="${id}" checked /><label class="form-check-label" for="${formId}">${address}</label></div>`
        $('.photograph_photograph_building_ids').append(html)
        $('#photograph_latitude').val(lat)
        $('#photograph_longitude').val(lon)
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
        if (card.find('#map').length && !this.mapInitialized) {
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

    selectFormat(el) {
        $('#physical-formats .list-group-item').removeClass('active')
        const id = $(el).closest('.list-group-item').addClass('active').attr('data-physical-format-id')
        $('#photograph_physical_format_id').val(id)
    }

    selectStatement(el) {
        $('#rights-statements .list-group-item').removeClass('active')
        const id = $(el).closest('.list-group-item').addClass('active').attr('data-rights-statement-id')
        $('#photograph_rights_statement_id').val(id)
    }

    initMap() {
        this.mapInitialized = true
        const startLat = document.getElementById('photograph_latitude').value
        const startLon = document.getElementById('photograph_longitude').value
        const loc = (startLat && startLon) ? [parseFloat(startLat), parseFloat(startLon)] : eval(document.getElementById('map').dataset.center)
        const map = new google.maps.Map(document.getElementById('map'), {
            center: {lat: loc[0], lng: loc[1]},
            zoom: 13
        })
        const marker = new google.maps.Marker({
            map: map,
            anchorPoint: new google.maps.Point(0, -29),
            draggable: true
        });

        marker.setPosition(map.getCenter())
        marker.setVisible(true)
        const input = document.getElementById('pac-input')
        const autocomplete = new google.maps.places.Autocomplete(input)
        autocomplete.bindTo('bounds', map)
        autocomplete.setFields(['address_components', 'geometry', 'icon', 'name'])
        autocomplete.addListener('place_changed', function () {
            marker.setVisible(false);
            const place = autocomplete.getPlace()
            if (!place.geometry) {
                window.alert("No details available for input: '" + place.name + "'")
                return
            }

            if (place.geometry.viewport) {
                map.fitBounds(place.geometry.viewport)
            } else {
                map.setCenter(place.geometry.location)
                map.setZoom(17)
            }
            marker.setPosition(place.geometry.location)
            document.getElementById('photograph_latitude').value = place.geometry.location.lat()
            document.getElementById('photograph_longitude').value = place.geometry.location.lng()

        });

        marker.addListener('dragend', function () {
            const position = marker.getPosition()
            document.getElementById('photograph_latitude').value = position.lat()
            document.getElementById('photograph_longitude').value = position.lng()
        })

        document.getElementById('photograph_longitude').addEventListener('change', function() {
            const lat = document.getElementById('photograph_latitude').value
            const lon = document.getElementById('photograph_longitude').value
            const loc = new google.maps.LatLng(parseFloat(lat), parseFloat(lon))
            marker.setPosition(loc)
            map.setCenter(loc)
        })
    }
}

$.fn.activateCard = function () {
    return this.each(function () {
        // $(this).addClass('activating')
        // window.setTimeout(() => {
            $(this).addClass('active')
        // }, 100)
        return this
    })
}

$.fn.deactivateCard = function () {
    return this.each(function () {
        $(this).removeClass('active') //.addClass('deactivating')
        // window.setTimeout(() => {
        //     $(this).removeClass('deactivating')
        // }, 1000)
        return this
    })
}