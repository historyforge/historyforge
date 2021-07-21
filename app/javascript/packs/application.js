/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

require.context('../images', true)

import '../../../vendor/assets/javascripts/parallax.min'
import '../../../vendor/assets/javascripts/jquery.mousewheel'
import '../../../vendor/assets/javascripts/chosen.jquery'
import '../../../vendor/assets/javascripts/blowup'

import '../css/application.scss'
import '../js/add_child'
import '../js/buildings'
import '../js/cell_renderers'
import '../js/add_child'
import '../js/advanced_search'
import '../js/census_form'
import '../js/home_page'
import '../js/photographs'
import '../js/terms'

import Rails from '@rails/ujs'
Rails.start()

import Cart from './../js/cart'
import "controllers"
import React from 'react'
import ReactDOM from 'react-dom'
import Forge from '../forge/App'
import MiniForge from '../miniforge/App'

window.cart = new Cart()

document.addEventListener('DOMContentLoaded', () => {
  const forge = document.getElementById('forge')
  if (forge) ReactDOM.render(<Forge />, forge)
  const miniforge = document.getElementById('miniforge')
  if (miniforge) ReactDOM.render(<MiniForge />, miniforge)

  window.alertifyInit = alertify.init
  $('[rel=tooltip]').tooltip()
  pageLoad()
})

window.showSubmitButton = function() {
  document.getElementById('contact-submit-btn').style.display = 'block'
}

const pageLoad = function() {
  window.alerts = window.alerts || []
  window.alertifyInit()
  alertify.set({delay: 10000})
  window.alerts.forEach(function(alert) {
    alertify[alert[0]](alert[1])
  })
  window.alerts = []
}

jQuery(document).on('click', '.dropdown-item.checkbox', function(e) { e.stopPropagation() })
jQuery(document).on('click', '#search-map', function() {
  const $form = jQuery(this).closest('form')
  if (document.location.toString().match(/building/))
    $form.append(`<input type="hidden" name="buildings" value="1">`)
  else {
    const year = jQuery(this).data('year')
    $form.append(`<input type="hidden" name="people" value="${year}">`)
  }
  $form.attr('action', '/forge')
  $form.submit()
})

// When the user fills address on census form, this refills the building_id dropdown
jQuery(document).on('blur', '#city, #street_name, #street_suffix', function() {
  let city = jQuery('#city').val()
  if (city === '') city = null
  let street = jQuery('#street_name').val()
  if (street === '') street = null
  let prefix = jQuery('#street_prefix').val()
  if (street === '') prefix = null
  let suffix = jQuery('#street_suffix').val()
  if (street === '') suffix = null
  if (city && street) {
    const params = {city, street, prefix, suffix}
    jQuery.getJSON('/census/1910/building_autocomplete', params, function (json) {
      const building = jQuery('#building_id')
      const current_value = building.val()
      let html = '<option value="">Select a building</option>'
      json.forEach(function (item) {
        html += `<option value="${item.id}">${item.name}</option>`
      })
      building.html(html)
      building.val(current_value)
    })
  }
})

let buildingNamed = false
jQuery(document).on('ready', function() {
  buildingNamed = jQuery('#building_name').val()
})

jQuery(document).on('change', '#building_address_house_number, #building_address_street_prefix, #building_address_street_name, #building_address_street_suffix', function() {
  if (buildingNamed) return
  const buildingName = [jQuery('#building_address_house_number').val(), jQuery('#building_address_street_prefix').val(), jQuery('#building_address_street_name').val(), jQuery('#building_address_street_suffix').val()].join(' ')
  jQuery('#building_name').val(buildingName)
})
