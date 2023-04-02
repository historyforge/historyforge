const selectScope = function(): void {
    const scope = $(this).val().toString();
    let name = `s[${scope}]`;
    const form = $(this).closest('.card-body').find('.value-input-container');
    const inputs = form.find('input, select');

    if (scope.match(/null$/)) {
        if (form.find('input.null-choice').length > 0) {
            inputs.filter(':checked').prop('checked', false);
            form.find('label').hide();
            form.find('input.null-choice').prop('disabled', false).attr('name', name);
        } else {
            inputs.attr('name', name);
        }
    } else {
        form.find('label').show();
        form.find('input.null-choice').prop('disabled', true);
        if (inputs.length > 1) {
            name += '[]';
        }
        inputs.attr('name', name);
    }
}

export default selectScope;
