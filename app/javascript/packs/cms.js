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

import 'trix/dist/trix.css'
import '../css/cms'

require('../js/cms_admin')
require("trix")
require("@rails/actiontext")
require("@rails/activestorage").start()

window.CodeMirror = require("codemirror")
require("codemirror/mode/css/css")
require("codemirror/mode/htmlmixed/htmlmixed")
require("codemirror/addon/edit/closetag")
require("codemirror/addon/edit/matchtags")
require("codemirror/addon/edit/matchbrackets")

$(document).ready(function() {
  $('a[data-toggle="tab"]').on('shown.bs.tab', function() {
    $('.CodeMirror').each(function() {
      this.CodeMirror.refresh()
    })
  })
  $('textarea.codemirror').each(function() {
    const { mode } = this.dataset || 'html'
    const editor = CodeMirror.fromTextArea(this, {
      lineNumbers: true,
      theme: 'darcula',
      mode
    });
    editor.setSize(null, 500)
  })
})

addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event
  const { id, file } = detail
  target.insertAdjacentHTML("beforebegin", `
    <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
      <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
      <span class="direct-upload__filename"></span>
    </div>
  `)
  target.previousElementSibling.querySelector(`.direct-upload__filename`).textContent = file.name
})

addEventListener("direct-upload:start", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.remove("direct-upload--pending")
})

addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail
  const progressElement = document.getElementById(`direct-upload-progress-${id}`)
  progressElement.style.width = `${progress}%`
})

addEventListener("direct-upload:error", event => {
  event.preventDefault()
  const { id, error } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--error")
  element.setAttribute("title", error)
})

addEventListener("direct-upload:end", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--complete")
})

