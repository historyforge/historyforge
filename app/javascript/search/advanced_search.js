import axios from 'axios'
import addAttributeFilter from "./addAttributeFilter";

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
    const field_config = window.attributeFilters[attribute];

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
                const field_config = this.getFieldConfigFromScope(scope) || this.getFieldConfigFromScope(scope.replace(/_eq/, '_in'))
                if (field_config || field_config.scopes) {
                    addAttributeFilter(field_config, scope, this.currentFilters[scope]);
                }
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

    getFieldConfigFromScope(scope) {
        for (let attribute in window.attributeFilters) {
            const value = window.attributeFilters[attribute];
            if ((value.scopes != null ? value.scopes[scope] : void 0) != null) {
                return value;
            }
        }
    }
}

