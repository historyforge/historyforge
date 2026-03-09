import { Controller } from 'stimulus'

// Renders the help text icon (?) and Bootstrap popover for census form hint bubbles.
// Uses Stimulus lifecycle so each hint gets exactly one icon—no accumulation when Turbo
// restores cached pages or when the form is re-rendered.
export default class extends Controller {
  connect() {
    const $hint = $(this.element)
    const $formGroup = $hint.closest('.form-group')
    const $label = $formGroup.children('label, .col-form-label').first()

    if ($label.length === 0) return

    // Skip if icon already present (e.g. from Turbo cache restore)
    if ($label.find('.fa-question-circle').length > 0) return

    const title = $(`<span>${$label.html()}<i class='fa fa-close float-right' /></span>`)
    const $icon = $('<i class="fa fa-question-circle float-right" data-toggle="popover" />')

    $label.prepend($icon)
    this.iconElement = $icon[0]

    title.on('click', () => $icon.popover('hide'))

    $icon
      .popover({ container: 'body', html: true, title, content: this.element.innerHTML, trigger: 'hover' })
      .on('show.bs.popover', () => $('[data-toggle=popover]').not($icon).popover('hide'))
      .on('click', function (e) {
        e.stopPropagation()
        e.preventDefault()
      })
  }

  disconnect() {
    if (!this.iconElement) return

    try {
      $(this.iconElement).popover('dispose')
    } catch (_e) {
      // Popover may already be disposed
    }
    try {
      $(this.iconElement).remove()
    } catch (_e) {
      // Element may already be removed with parent
    }
  }
}
