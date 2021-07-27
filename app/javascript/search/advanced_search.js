import axios from 'axios'

const getFieldConfig = function(attribute) {
    let key, value;
    const ref = window.attributeFilters
    for (key in ref) {
        value = ref[key];
        if (attribute === key) {
            return value;
        }
    }
};

const getFieldConfigFromScope = function(scope) {
    var attribute, ref, ref1, value;
    ref = window.attributeFilters;
    for (attribute in ref) {
        value = ref[attribute];
        if (((ref1 = value.scopes) != null ? ref1[scope] : void 0) != null) {
            return value;
        }
    }
};

const addAttributeFilter = function(scope, scopeValue) {
    let html, input;
    if (scope === 'reviewed_at_null') {
        html = document.createElement('DIV');
        html.classList.add('attribute-filter');
        html.classList.add('dropdown-item');
        html.innerHTML = 'Unreviewed records';
        $('#attribute-filters').append(html);
        return;
    }
    if (scope === 'building_id_null') {
        html = document.createElement('DIV');
        html.classList.add('attribute-filter');
        html.classList.add('dropdown-item');
        html.innerHTML = 'Records not attached to buildings';
        $('#attribute-filters').append(html);
        return;
    }
    const field_config = getFieldConfigFromScope(scope) || getFieldConfigFromScope(scope.replace(/_eq/, '_in'))

    if (!field_config || !field_config.scopes) {
        return;
    }

    html = document.createElement('DIV');
    ['attribute-filter', 'btn', 'btn-sm', 'btn-light'].forEach((text) => {
        html.classList.add(text)
    })

    const sentence = [field_config.label];

    for (let key in field_config.scopes) {
        const value = field_config.scopes[key];
        if (key === scope) {
            sentence.push(value);
        }
    }

    if (scope.match(/null$/)) {
        input = document.createElement('INPUT');
        input.setAttribute('type', 'hidden');
        input.setAttribute('name', `s[${scope}]`);
        input.setAttribute('value', '1');
        html.appendChild(input);
    } else {
        switch (field_config.type) {
            case 'boolean':
                input = document.createElement('INPUT');
                input.setAttribute('type', 'hidden');
                input.setAttribute('name', `s[${scope}]`);
                input.setAttribute('value', '1');
                html.appendChild(input);
                break;

            case 'checkboxes':
                const values = [];
                field_config.choices.forEach((choice) => {
                    let label, value;
                    if (typeof choice === 'string') {
                        label = value = choice;
                    } else {
                        [label, value ] = choice;
                    }
                    scopeValue.forEach((singleScopeValue) => {
                        if (value.toString() === singleScopeValue.toString()) {
                            values.push(label);
                            input = document.createElement('INPUT');
                            input.setAttribute('type', 'hidden');
                            input.setAttribute('name', `s[${scope}][]`);
                            input.setAttribute('value', singleScopeValue);
                            html.appendChild(input);
                        }
                    })
                })
                sentence.push(values.join(', '));
                break;

            case 'text':
                input = document.createElement('INPUT');
                input.setAttribute('type', 'hidden');
                input.setAttribute('name', `s[${scope}]`);
                input.setAttribute('value', scopeValue);
                html.appendChild(input);
                sentence.push(`"${scopeValue}"`)
                break;

            case 'number':
                input = document.createElement('INPUT');
                input.setAttribute('type', 'hidden');
                input.setAttribute('name', `s[${scope}]`);
                input.setAttribute('value', scopeValue);
                html.appendChild(input);
                sentence.push(scopeValue);
                break;

            case 'dropdown':
                input = document.createElement('INPUT');
                input.setAttribute('type', 'hidden');
                input.setAttribute('name', `s[${scope}]`);
                input.setAttribute('value', scopeValue);
                html.appendChild(input);

                field_config.choices.forEach((choice) => {
                    if (scopeValue === choice.toString()) {
                        sentence.push(choice);
                    }
                })
                break;

            case 'daterange':
                const input1 = document.createElement('INPUT');
                input1.setAttribute('type', 'hidden');
                input1.setAttribute('name', `s[${scope}]`);
                input1.setAttribute('name', "s[" + scope + "]");
                input1.setAttribute('value', scopeValue);
                html.appendChild(input1);

                const otherScope = scope.replace(/gteq/, 'lteq');
                const otherValue = window.currentAttributeFilters[otherScope];
                const input2 = document.createElement('INPUT');
                input2.setAttribute('type', 'hidden');
                input2.setAttribute('name', `s[${otherScope}]`);
                input2.setAttribute('value', otherValue);
                html.appendChild(input2);
                sentence.push(moment(scopeValue).format('M/D/YY'));
                sentence.push(' to ');
                sentence.push(moment(otherValue).format('M/D/YY'));
        }
    }
    const closeButton = document.createElement('BUTTON');
    closeButton.type = 'button';
    closeButton.classList.add('close');
    closeButton.classList.add('remove-filter');
    closeButton.innerHTML = "&times;";

    const desc = document.createElement('SPAN');
    desc.appendChild(closeButton);
    desc.innerHTML += sentence.join(' ');
    if (field_config.append) {
        desc.innerHTML += field_config.append;
    }
    html.appendChild(desc);
    $('#attribute-filters').append(html);
};

jQuery(document).on('click', '.attribute-filter button.close', function() {
    const $filter = $(this).closest('.attribute-filter')
    const name = $filter.find('input:first').attr('name')

    $(`[name="${name}"]`).val(null)
    $(`[name="${name.replace('[]', '')}"]`).val(null)
    $(`[name="${name.replace('_in', '_eq')}"]`).val(null)

    $filter.remove();
    $('#new_s').submit();
});

$(document).on('click', '#new_s .btn-group-toggle label', function() {
    return $('#new_s').submit();
});

$(document).on('click', '.checkall', function(e) {
    e.stopPropagation();
    const $cont = $($(this).data('scope'));
    const $inputs = $cont.find('input[type=checkbox]');
    const checks = $inputs.filter(':checked').length;
    if (checks) {
        if (checks === $inputs.length) {
            $inputs.removeAttr('checked');
            $inputs.filter("[data-default=true]").trigger('click');
        } else {
            $inputs.filter(':not(:checked)').trigger('click');
        }
    } else {
        $inputs.trigger('click');
    }
});

$(document).on('change', 'select.scope', function() {
    const scope = jQuery(this).val();
    let name = 's[' + scope + ']';
    const form = jQuery(this).closest('.card-body').find('.value-input-container');
    const inputs = form.find('input, select');
    if (scope.match(/null$/)) {
        if (form.find('input.null-choice').size() > 0) {
            inputs.filter(':checked').prop('checked', false);
            form.find('label').hide();
            form.find('input.null-choice').prop('disabled', false).attr('name', name);
        } else {
            inputs.attr('name', name);
        }
    } else {
        form.find('label').show();
        form.find('input.null-choice').prop('disabled', true);
        if (inputs.size() > 1) {
            name += '[]';
        }
        inputs.attr('name', name);
    }
});

$(document).on('change', 'select.attribute', function() {
    const attribute = $(this).val();
    const form = $(this).closest('.card-body');
    const field_config = getFieldConfig(attribute);

    if (field_config) {
        const scopeSelectContainer = form.find('.scope-selection-container').empty().hide();
        const scopeSelect = $('<select class="scope form-control"></select>');

        for (let key in field_config.scopes) {
            const value = field_config.scopes[key];
            scopeSelect.append(`<option value="${key}" ">${value}</option>`);
        }

        scopeSelect.find('option:first').prop('selected', true);
        if (scopeSelect.find('option').size() === 1) {
            scopeSelect.hide();
            scopeSelectContainer.append(jQuery('<span>' + scopeSelect.find('option:first').text() + '</span>'));
        }
        scopeSelectContainer.append(scopeSelect).css('display', 'inline');

        const valueBox = form.find('.value-input-container');
        valueBox.hide().empty().prop('className', 'value-input-container col-6').addClass(field_config.type);
        if (field_config.columns) {
            valueBox.addClass('column-count-' + field_config.columns);
        }
        scopeSelect.on('change', function() {
            const $input = valueBox.find('input');
            if ($(this).val().match(/y_term/)) {
                $input.attr('placeholder', 'spaces separate "multiple words"');
            }
            if ($input.length === 1) {
                return $input.focus();
            }
        });

        const appendToValueBox = function(input) {
            if (field_config.append) {
                const div = document.createElement('DIV');
                div.className = 'input-append';
                const span = document.createElement('SPAN');
                span.className = 'add-on';
                span.appendChild(document.createTextNode(field_config.append));
                div.appendChild(input);
                div.appendChild(span);
                valueBox.append(div);
            } else {
                valueBox.append(input);
            }
            valueBox.css('display', 'inline');
        };

        let input;

        switch (field_config.type) {
            case 'boolean':
                input = document.createElement('INPUT');
                input.setAttribute('name', `s[${scopeSelect.val()}]`);
                input.setAttribute('type', 'hidden');
                input.setAttribute('value', '1');
                appendToValueBox(input);
                break;

            case 'checkboxes':
                const null_choice = document.createElement('INPUT');
                null_choice.type = 'hidden';
                null_choice.disabled = true;
                null_choice.className = 'null-choice';
                null_choice.value = 1;
                valueBox.append(null_choice);
                field_config.choices.forEach((choice) => {
                    let labelText, value;
                    if (typeof choice === 'string') {
                        labelText = value = choice;
                    } else {
                        [labelText, value] = choice;
                    }

                    const name = `s[${scopeSelect.val()}][]`;
                    const id = `s_${scopeSelect.val()}_${value}`;
                    const checkbox = document.createElement('DIV');
                    checkbox.classList.add('form-check');
                    input = document.createElement('INPUT');
                    input.classList.add('form-check-input');
                    input.setAttribute('type', 'checkbox');
                    input.setAttribute('id', id);
                    input.setAttribute('name', name);
                    input.setAttribute('value', value);
                    checkbox.appendChild(input);
                    const label = document.createElement('LABEL');
                    label.setAttribute('for', id);
                    label.className = 'form-check-label';
                    label.appendChild(document.createTextNode(labelText));
                    checkbox.appendChild(label);
                    valueBox.append(checkbox);
                })
                valueBox.css('display', 'inline');
                break;

            case 'text':
                input = document.createElement('INPUT');
                input.classList.add('form-control');
                input.setAttribute('name', `s[${scopeSelect.val()}]`);
                input.setAttribute('type', 'text');
                appendToValueBox(input);
                break;

            case 'number':
            case 'age':
            case 'time':
                input = document.createElement('INPUT');
                input.classList.add('form-control');
                input.setAttribute('name', `s[${scopeSelect.val()}]`);
                input.setAttribute('type', 'number');
                appendToValueBox(input);
                scopeSelect.bind('change', function() {
                    const val = jQuery(this).val();
                    if (val.match(/null/)) {
                        if (input.getAttribute('type') === 'number') {
                            input.setAttribute('type', 'hidden');
                            input.setAttribute('value', '1');
                        }
                    } else if (input.getAttribute('type') === 'hidden') {
                        input.setAttribute('type', 'number');
                        input.setAttribute('value', null);
                    }
                });
                break;

            case 'dropdown':
                input = document.createElement('SELECT');
                input.classList.add('form-control');
                input.setAttribute('name', `s[${scopeSelect.val()}]`);
                field_config.choices.forEach((choice) => {
                    const option = document.createElement('OPTION');
                    option.setAttribute('value', choice);
                    option.innerText = choice;
                    input.appendChild(option);
                })
                appendToValueBox(input);
                break;

            case 'daterange':
                const startDate = moment().startOf('month');
                const endDate = moment().endOf('month');
                const div = $('<div class="picker"></div>');
                div.append(jQuery('<i class="icon-calendar.icon-large"></i>'));
                div.append(`<span>${startDate.format('M/D/YY')} - ${endDate.format('M/D/YY')}</span><b class="caret"></b>`);
                div.css('display', 'inline');

                const from = document.createElement('INPUT');
                from.setAttribute('type', 'hidden');
                from.setAttribute('name', `s[${scopeSelect.val()}]`);
                from.setAttribute('value', startDate.format('YYYY-MM-DD'));
                from.className = 'from';

                const to = document.createElement('INPUT');
                to.setAttribute('type', 'hidden');
                to.setAttribute('name', `s[${scopeSelect.val().replace(/gteq/, 'lteq')}]`);
                to.setAttribute('value', endDate.format('YYYY-MM-DD'));
                to.className = 'to';

                valueBox.append(from);
                valueBox.append(to);
                appendToValueBox(div);
                valueBox.searchDateRange(startDate, endDate);
        }
    }
});

$.fn.advancedSearch = function(options) {
    return this.each(function() {
        $(this).data('search', new AdvancedSearch(options));
        return this;
    })
};

class AdvancedSearch {
    constructor(options) {
        options = options || {};
        this.currentFilters = options.filters;

        axios.get(options.url).then((json) => {
            window.attributeFilters = json.data.filters;
            this.showCurrentFilters()
            this.showAddableFilters();
        })
    }

    showCurrentFilters() {
        if (Object.entries(this.currentFilters).length) {
            $('#attribute-filters').addClass('mb-3').empty();
            for (let scope in this.currentFilters) {
                addAttributeFilter(scope, this.currentFilters[scope]);
            }
        }
    }

    showAddableFilters() {
        $('select.scope').hide();
        $('.value-input-container').empty();
        const attrSelect = $('select.attribute');
        attrSelect.html("<option>Select field name</option>");
        for (let key in window.attributeFilters) {
            const config = window.attributeFilters[key];
            if (config.scopes) {
                attrSelect.append('<option value="' + key + '">' + config.label + '</option>');
            }
        }
    }
}

$.fn.searchDateRange = function(from, to) {
    return this.each(function() {
        const dateRangeOptions = {
            startDate: from,
            endDate: to,
            opens: 'left',
            alwaysShowCalendars: true,
            ranges: {
                'Today': [moment(), moment()],
                'Yesterday': [moment().subtract('days', 1), moment().subtract('days', 1)],
                'Last 7 Days': [moment().subtract('days', 6), moment()],
                'Last 30 Days': [moment().subtract('days', 29), moment()],
                'This Month': [moment().startOf('month'), moment().endOf('month')],
                'Last Month': [moment().subtract('month', 1).startOf('month'), moment().subtract('month', 1).endOf('month')],
                'This Year': [moment().startOf('year'), moment()],
                'Last Year': [moment().subtract('years', 1).startOf('year'), moment().subtract('years', 1).endOf('year')]
            }
        };
        const fromInput = $(this).find('.from');
        const toInput = $(this).find('.to');
        const picker = $(this).find('.picker');
        picker.daterangepicker(dateRangeOptions, function(start, end) {
            start = moment(start);
            end = moment(end);
            picker.find('span').html(start.format('M/D/YYYY') + ' - ' + end.format('M/D/YYYY'));
            fromInput.val(start.format('YYYY-MM-DD'));
            return toInput.val(end.format('YYYY-MM-DD'));
        });
        return this;
    });
};