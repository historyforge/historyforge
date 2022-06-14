$.fn.extend({
  disableWrapper: function () {
    return this.each(function () {
      return $(this).addClass('disabled').find('input').attr('disabled', true)
    })
  },
  enableWrapper: function () {
    return this.each(function () {
      return $(this).removeClass('disabled').find('input').removeAttr('disabled', true)
    })
  },
  toggleDependents: function () {
    return this.each(function () {
      const value = $(this).is('[type=checkbox]') ? $(this).is(':checked') : $(this).val()
      const name = this.getAttribute('name')
      const attribute_name = name.match(/census_record\[(\w+)]/)[1]
      const dependent = $(this).closest('[data-dependents]').attr('data-dependents')
      if (value.toString() === dependent.toString()) { $(`.form-group[data-depends-on=${attribute_name}]`).enableWrapper() } else { $(`.form-group[data-depends-on=${attribute_name}]`).disableWrapper() }
    })
  }
})

$(function() {
  const $forms = $('#new_census_record, #edit_census_record')

  $forms.on('keypress', function (e) {
    const code = e.keyCode || e.which
    if (code === 13) {
      e.preventDefault()
      return false
    }
  })

  $forms.find('input[data-type=other-radio-button]').each(function () {
    if (!$(this).val().length) { $(this).attr('disabled', true) }
  })

  $forms.find('input[type=radio][value!=other]').on('click', function () {
    const $input = $(this).closest('.form-group').find('input[data-type=other-radio-button]')
    $input.val(null).attr('disabled', true)
  })

  $forms.find('input[type=radio][value=other]').on('click', function () {
    const $input = $(this).next().find('input')
    if ($(this).is(':checked')) { $input.removeAttr('disabled').focus() } else { $input.attr('disabled', true) }
  })

  $('input[data-type="other-radio-button"]').on('change', function () {
    $(this).closest('.form-check').find('input[type=radio]').prop('checked', true).val($(this).val())
  })

  $('[data-dependents] input').on('change click', function () {
    $(this).toggleDependents()
  })

  $('[data-dependents]').find('input[type=radio]:checked, input[type=checkbox], input[type=text]').toggleDependents()

  $('.census1930_record_census_record_war_fought').find('input[type=radio]').on('click', function () {
    const war_fought = $('input[name="census_record[war_fought]"]:checked').val()
    $('#census_record_veteran').attr('checked', war_fought.length && war_fought !== 'on')
  })

  $('.hint-bubble').each(function () {
    const label = $(this).closest('.form-group').children('label, .col-form-label')
    const title = $(`<span>${label.html()}<i class='fa fa-close float-right' /></span>`)
    const icon = $('<i class="fa fa-question-circle float-right" data-toggle="popover" />')
    label.prepend(icon)
    title.on('click', () => icon.popover('hide'))
    icon
      .popover({ container: 'body', html: true, title, content: this.innerHTML, trigger: 'hover' })
      .on('show.bs.popover', () => $('[data-toggle=popover]').popover('hide'))
      .on('click', function (e) {
        e.stopPropagation()
        e.preventDefault()
      })
  })
})

$(document).on('change', '#census_record_page_side', function() {
  const value = $(this).val()
  const $line = $('#census_record_line_number')
  if (value === 'A') {
    $line.attr('min', 1)
    $line.attr('max', 50)
  } else {
    $line.attr('min', 51)
    $line.attr('max', 100)
  }
})

$(document).on('change', '#census_record_sex', function() {
  const value = $(this).val()
  if (value === 'M') {
    $('#census_record_num_children_born').val(null).prop('disabled', true)
    $('#census_record_num_children_alive').val(null).prop('disabled', true)
  } else if (value === 'F') {
    $('#census_record_num_children_born').prop('disabled', false)
    $('#census_record_num_children_alive').prop('disabled', false)
  }
})

$(document).on('change', '#census_record_marital_status', function() {
  const value = $(this).val()
  if (value === 'S' || value === 'D') { $('#census_record_years_married').val(null).prop('disabled', true) } else { $('#census_record_years_married').val(null).prop('disabled', false) }
})
