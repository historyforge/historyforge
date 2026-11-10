require('./js/cms_admin')
require('@rails/activestorage').start()

window.CodeMirror = require('codemirror')
require('codemirror/mode/css/css')
require('codemirror/mode/htmlmixed/htmlmixed')
require('codemirror/addon/edit/closetag')
require('codemirror/addon/edit/matchtags')
require('codemirror/addon/edit/matchbrackets')

document.addEventListener('shown.bs.tab', () => {
  document.querySelectorAll('.CodeMirror').forEach(editor => editor.CodeMirror.refresh())
})

window.initializeCMS = () => {
  document.querySelectorAll('textarea.codemirror').forEach(textarea => {
    if (textarea.nextElementSibling?.classList.contains('CodeMirror')) return
    const editor = window.CodeMirror.fromTextArea(textarea, {
      lineNumbers: true,
      theme: 'darcula',
      mode: textarea.dataset.mode || 'htmlmixed'
    })
    editor.setSize(null, 500)
  })
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', window.initializeCMS, { once: true })
} else {
  window.initializeCMS()
}
document.addEventListener('turbo:load', window.initializeCMS)

addEventListener('direct-upload:initialize', event => {
  const { target, detail } = event
  const { id, file } = detail
  target.insertAdjacentHTML('beforebegin', `
    <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
      <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
      <span class="direct-upload__filename"></span>
    </div>
  `)
  target.previousElementSibling.querySelector('.direct-upload__filename').textContent = file.name
})

addEventListener('direct-upload:start', event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.remove('direct-upload--pending')
})

addEventListener('direct-upload:progress', event => {
  const { id, progress } = event.detail
  const progressElement = document.getElementById(`direct-upload-progress-${id}`)
  progressElement.style.width = `${progress}%`
})

addEventListener('direct-upload:error', event => {
  event.preventDefault()
  const { id, error } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add('direct-upload--error')
  element.setAttribute('title', error)
})

addEventListener('direct-upload:end', event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add('direct-upload--complete')
})
