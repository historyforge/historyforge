$(document).on('click', '.nested-form-item .remove', function(e) {
    e.preventDefault();
    e.stopPropagation();

    const item = $(this).closest('.nested-form-item')
    const destroy = item.find('[name*="_destroy"]')
    if (destroy.length) {
        const destroy = item.find('[name*="_destroy"]')
        destroy.val(1)
        item.addClass('removed')
    } else {
        item.remove()
    }
})

$(document).on('click', '[data-insert-fields]', function() {
    const method = $(this).attr('data-insert-fields')
    const content = $('#' + method + '_fields').html()
    const formSelector = $(this).attr('data-form-selector')
    insert_fields(this, method, content, formSelector)
})

window.insert_fields = (link, method, content, formSelector) => {
    const new_id = new Date().getTime()
    method = method.split('_')
    method.pop()
    method = method.join('_')
    const regexp = new RegExp("new_" + method, "g")
    const form = formSelector && formSelector.length ? $(formSelector) : $(link).closest('.nested-form')
    const target = form.children('.nested-form-items')
    console.log(form, target)
    content = $(content.replace(regexp, new_id))
    target.append(content).find('.nested-form-item:last').removeClass('collapsed') //.find('select').initChosen()
    return false
}
