const getFieldConfig = function(attribute) {
    var key, ref, value;
    ref = window.attributeFilters["filters"];
    for (key in ref) {
        value = ref[key];
        if (attribute === key) {
            return value;
        }
    }
};

const getFieldConfigFromScope = function(scope) {
    var attribute, ref, ref1, value;
    ref = window.attributeFilters["filters"];
    for (attribute in ref) {
        value = ref[attribute];
        if (((ref1 = value.scopes) != null ? ref1[scope] : void 0) != null) {
            return value;
        }
    }
};

const getSortableFields = function() {
    const fields = {};
    window.attributeFilters.filters.forEach((filter) => {
        if (filter.sortable) {
            fields[filter.sortable] = filter.label
        }
    })
    return fields;
};

const addAttributeFilter = function(scope, scopeValue) {
    var choice, closeButton, desc, field_config, html, i, input, input1, input2, j, k, key, label, len, len1, len2, otherScope, otherValue, ref, ref1, ref2, sentence, singleScopeValue, value, values;
    if (scope === 'reviewed_at_null') {
        html = document.createElement('DIV');
        html.classList.add('attribute-filter');
        html.classList.add('dropdown-item');
        html.innerHTML = 'Unreviewed records';
        jQuery('#attribute-filters').append(html);
        return;
    }
    if (scope === 'building_id_null') {
        html = document.createElement('DIV');
        html.classList.add('attribute-filter');
        html.classList.add('dropdown-item');
        html.innerHTML = 'Records not attached to buildings';
        jQuery('#attribute-filters').append(html);
        return;
    }
    field_config = getFieldConfigFromScope(scope);
    if (!field_config)
        field_config = getFieldConfigFromScope(scope.replace(/_eq/, '_in'))

    if (field_config == null) {
        return;
    }
    if (field_config.scopes == null) {
        return;
    }
    html = document.createElement('DIV');
    ['attribute-filter', 'btn', 'btn-sm', 'btn-light'].forEach((text) => {
        html.classList.add(text)
    })
    sentence = [field_config.label];
    ref = field_config.scopes;
    for (key in ref) {
        value = ref[key];
        if (key === scope) {
            sentence.push(value);
        }
    }
    if (scope.match(/null$/)) {
        input = document.createElement('INPUT');
        input.setAttribute('type', 'hidden');
        input.setAttribute('name', "s[" + scope + "]");
        input.setAttribute('value', 1);
        html.appendChild(input);
    } else {
        switch (field_config.type) {
            case 'boolean':
                input = document.createElement('INPUT');
                input.setAttribute('type', 'hidden');
                input.setAttribute('name', "s[" + scope + "]");
                input.setAttribute('value', '1');
                html.appendChild(input);
                break;
            case 'checkboxes':
                values = [];
                ref1 = field_config.choices;
                for (i = 0, len = ref1.length; i < len; i++) {
                    choice = ref1[i];
                    if (typeof choice === 'string') {
                        label = value = choice;
                    } else {
                        label = choice[0], value = choice[1];
                    }
                    for (j = 0, len1 = scopeValue.length; j < len1; j++) {
                        singleScopeValue = scopeValue[j];
                        if (value.toString() === singleScopeValue.toString()) {
                            values.push(label);
                            input = document.createElement('INPUT');
                            input.setAttribute('type', 'hidden');
                            input.setAttribute('name', "s[" + scope + "][]");
                            input.setAttribute('value', singleScopeValue);
                            html.appendChild(input);
                        }
                    }
                }
                values = values.join(', ');
                sentence.push(values);
                break;
            case 'text':
                input = document.createElement('INPUT');
                input.setAttribute('type', 'hidden');
                input.setAttribute('name', "s[" + scope + "]");
                input.setAttribute('value', scopeValue);
                html.appendChild(input);
                sentence.push('"' + scopeValue + '"');
                break;
            case 'number':
                input = document.createElement('INPUT');
                input.setAttribute('type', 'hidden');
                input.setAttribute('name', "s[" + scope + "]");
                input.setAttribute('value', scopeValue);
                html.appendChild(input);
                sentence.push(scopeValue);
                break;
            case 'dropdown':
                input = document.createElement('INPUT');
                input.setAttribute('type', 'hidden');
                input.setAttribute('name', "s[" + scope + "]");
                input.setAttribute('value', scopeValue);
                html.appendChild(input);
                ref2 = field_config.choices;
                for (k = 0, len2 = ref2.length; k < len2; k++) {
                    choice = ref2[k];
                    label = value = choice;
                    if (scopeValue === value.toString()) {
                        sentence.push(label);
                    }
                }
                break;
            case 'daterange':
                input1 = document.createElement('INPUT');
                input1.setAttribute('type', 'hidden');
                input1.setAttribute('name', "s[" + scope + "]");
                input1.setAttribute('value', scopeValue);
                html.appendChild(input1);
                otherScope = scope.replace(/gteq/, 'lteq');
                otherValue = window.currentAttributeFilters[otherScope];
                input2 = document.createElement('INPUT');
                input2.setAttribute('type', 'hidden');
                input2.setAttribute('name', "s[" + otherScope + "]");
                input2.setAttribute('value', otherValue);
                html.appendChild(input2);
                sentence.push(moment(scopeValue).format('M/D/YY'));
                sentence.push(' to ');
                sentence.push(moment(otherValue).format('M/D/YY'));
        }
    }
    closeButton = document.createElement('BUTTON');
    closeButton.type = 'button';
    closeButton.classList.add('close');
    closeButton.classList.add('remove-filter');
    closeButton.innerHTML = "&times;";
    desc = document.createElement('SPAN');
    desc.appendChild(closeButton);
    desc.innerHTML += sentence.join(' ');
    if (field_config.append) {
        desc.innerHTML += field_config.append;
    }
    html.appendChild(desc);
    return jQuery('#attribute-filters').append(html);
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

jQuery(document).on('click', '.checkall', function(e) {
    var $cont, $inputs, checks;
    e.stopPropagation();
    $cont = $($(this).data('scope'));
    $inputs = $cont.find('input[type=checkbox]');
    checks = $inputs.filter(':checked').length;
    if (checks) {
        if (checks === $inputs.length) {
            $inputs.removeAttr('checked');
            return $inputs.filter("[data-default=true]").trigger('click');
        } else {
            return $inputs.filter(':not(:checked)').trigger('click');
        }
    } else {
        return $inputs.trigger('click');
    }
});

jQuery(document).on('change', 'select.scope', function() {
    var form, inputs, name, scope;
    scope = jQuery(this).val();
    name = 's[' + scope + ']';
    form = jQuery(this).closest('.card-body').find('.value-input-container');
    inputs = form.find('input, select');
    if (scope.match(/null$/)) {
        if (form.find('input.null-choice').size() > 0) {
            inputs.filter(':checked').prop('checked', false);
            form.find('label').hide();
            return form.find('input.null-choice').prop('disabled', false).attr('name', name);
        } else {
            return inputs.attr('name', name);
        }
    } else {
        form.find('label').show();
        form.find('input.null-choice').prop('disabled', true);
        if (inputs.size() > 1) {
            name += '[]';
        }
        return inputs.attr('name', name);
    }
});

jQuery(document).on('change', 'select.attribute', function() {
    var appendToValueBox, attribute, checkbox, choice, choices, div, endDate, field_config, form, from, i, id, input, j, key, label, labelText, len, len1, name, null_choice, option, ref, ref1, scopeSelect, scopeSelectContainer, startDate, to, value, valueBox;
    attribute = jQuery(this).val();
    form = jQuery(this).closest('.card-body');
    field_config = getFieldConfig(attribute);
    if (field_config) {
        scopeSelectContainer = form.find('.scope-selection-container');
        scopeSelectContainer.empty().hide();
        scopeSelect = document.createElement('SELECT');
        scopeSelect.classList.add('scope');
        scopeSelect.classList.add('form-control');
        scopeSelect = jQuery(scopeSelect);
        ref = field_config.scopes;
        for (key in ref) {
            value = ref[key];
            scopeSelect.append("<option value=\"" + key + "\">" + value + "</option>");
        }
        scopeSelect.find('option:first').prop('selected', true);
        if (scopeSelect.find('option').size() === 1) {
            scopeSelect.hide();
            scopeSelectContainer.append(jQuery('<span>' + scopeSelect.find('option:first').text() + '</span>'));
        }
        scopeSelectContainer.append(scopeSelect).css('display', 'inline');
        valueBox = form.find('.value-input-container');
        valueBox.hide().empty().prop('className', 'value-input-container col-6').addClass(field_config.type);
        if (field_config.columns) {
            valueBox.addClass('column-count-' + field_config.columns);
        }
        scopeSelect.on('change', function() {
            var $input;
            $input = valueBox.find('input');
            if ($(this).val().match(/y_term/)) {
                $input.attr('placeholder', 'spaces separate "multiple words"');
            }
            if ($input.length === 1) {
                return $input.focus();
            }
        });
        appendToValueBox = function(input) {
            var div, span;
            if (field_config.append) {
                div = document.createElement('DIV');
                div.className = 'input-append';
                span = document.createElement('SPAN');
                span.className = 'add-on';
                span.appendChild(document.createTextNode(field_config.append));
                div.appendChild(input);
                div.appendChild(span);
                valueBox.append(div);
            } else {
                valueBox.append(input);
            }
            return valueBox.css('display', 'inline');
        };
        switch (field_config.type) {
            case 'boolean':
                name = "s[" + scopeSelect.val() + "]";
                input = document.createElement('INPUT');
                input.setAttribute('name', name);
                input.setAttribute('type', 'hidden');
                input.setAttribute('value', '1');
                appendToValueBox(input);
                break;
            case 'checkboxes':
                null_choice = document.createElement('INPUT');
                null_choice.type = 'hidden';
                null_choice.disabled = true;
                null_choice.className = 'null-choice';
                null_choice.value = 1;
                valueBox.append(null_choice);
                ref1 = field_config.choices;
                for (i = 0, len = ref1.length; i < len; i++) {
                    choice = ref1[i];
                    if (typeof choice === 'string') {
                        labelText = value = choice;
                    } else {
                        labelText = choice[0], value = choice[1];
                    }
                    name = 's[' + scopeSelect.val() + '][]';
                    id = 's_' + scopeSelect.val() + '_' + value;
                    checkbox = document.createElement('DIV');
                    checkbox.classList.add('form-check');
                    input = document.createElement('INPUT');
                    input.classList.add('form-check-input');
                    input.setAttribute('type', 'checkbox');
                    input.setAttribute('id', id);
                    input.setAttribute('name', name);
                    input.setAttribute('value', value);
                    checkbox.appendChild(input);
                    label = document.createElement('LABEL');
                    label.setAttribute('for', id);
                    label.className = 'form-check-label';
                    label.appendChild(document.createTextNode(labelText));
                    checkbox.appendChild(label);
                    valueBox.append(checkbox);
                }
                valueBox.css('display', 'inline');
                break;
            case 'text':
                name = "s[" + (scopeSelect.val()) + "]";
                input = document.createElement('INPUT');
                input.classList.add('form-control');
                input.setAttribute('name', name);
                input.setAttribute('type', 'text');
                appendToValueBox(input);
                break;
            case 'number':
            case 'age':
            case 'time':
                name = "s[" + (scopeSelect.val()) + "]";
                input = document.createElement('INPUT');
                input.classList.add('form-control');
                input.setAttribute('name', name);
                input.setAttribute('type', 'number');
                appendToValueBox(input);
                scopeSelect.bind('change', function() {
                    var val;
                    val = jQuery(this).val();
                    if (val.match(/null/)) {
                        if (input.getAttribute('type') === 'number') {
                            input.setAttribute('type', 'hidden');
                            input.setAttribute('value', '1');
                        }
                    } else if (input.getAttribute('type') === 'hidden') {
                        input.setAttribute('type', 'number');
                        input.setAttribute('value', null);
                    }
                    return true;
                });
                break;
            case 'dropdown':
                choices = field_config.choices;
                name = "s[" + (scopeSelect.val()) + "]";
                input = document.createElement('SELECT');
                input.classList.add('form-control');
                input.setAttribute('name', name);
                for (j = 0, len1 = choices.length; j < len1; j++) {
                    choice = choices[j];
                    label = value = choice;
                    option = document.createElement('OPTION');
                    jQuery(option).val(value);
                    jQuery(option).text(label);
                    input.appendChild(option);
                }
                appendToValueBox(input);
                break;
            case 'daterange':
                startDate = moment().startOf('month');
                endDate = moment().endOf('month');
                div = jQuery('<div class="picker"></div>');
                div.append(jQuery('<i class="icon-calendar.icon-large"></i>'));
                div.append("<span>" + (startDate.format('M/D/YY')) + " - " + (endDate.format('M/D/YY')) + "</span><b class=\"caret\"></b>");
                div.css('display', 'inline');
                from = document.createElement('INPUT');
                from.setAttribute('type', 'hidden');
                from.setAttribute('name', "s[" + (scopeSelect.val()) + "]");
                from.setAttribute('value', startDate.format('YYYY-MM-DD'));
                from.className = 'from';
                to = document.createElement('INPUT');
                to.setAttribute('type', 'hidden');
                to.setAttribute('name', "s[" + (scopeSelect.val().replace(/gteq/, 'lteq')) + "]");
                to.setAttribute('value', endDate.format('YYYY-MM-DD'));
                to.className = 'to';
                valueBox.append(from);
                valueBox.append(to);
                appendToValueBox(div);
                valueBox.searchDateRange(startDate, endDate);
        }
    }
});

jQuery.fn.advancedSearch = function(options) {
    if (options == null) {
        options = {};
    }
    return this.each(function() {
        var attributeFiltersCallback, fields, filters, json, last_load, sorts, url;
        url = options.url;
        fields = options.fields;
        filters = options.filters;
        sorts = options.sorts;
        attributeFiltersCallback = function(json) {
            var c, d, key, ref, scope, value;
            window.attributeFilters = json;
            window.sortedAttributeFilters = [];
            ref = json['filters'];
            for (key in ref) {
                value = ref[key];
                window.sortedAttributeFilters.push({
                    key,
                    label: value.label,
                    value
                });
            }
            if (Object.entries(filters).length) {
                $('#attribute-filters').addClass('mb-3').empty();
                for (scope in filters) {
                    value = filters[scope];
                    addAttributeFilter(scope, value);
                }
            }
            if (sorts) {
                c = sorts.c;
                d = sorts.d;
                jQuery('#c').each(function() {
                    var label, option;
                    fields = getSortableFields();
                    for (value in fields) {
                        label = fields[value];
                        option = document.createElement('OPTION');
                        jQuery(option).val(value);
                        jQuery(option).text(label);
                        jQuery(this).on('change', function() {
                            return $('#new_s').submit();
                        });
                        this.appendChild(option);
                    }
                    return jQuery(this).val(c);
                });
                return jQuery('#d').each(function() {
                    jQuery(this).append('<option value="asc">up</option><option value="desc">down</option>');
                    jQuery(this).val(d);
                    return jQuery(this).on('change', function() {
                        return $('#new_s').submit();
                    });
                });
            }
        };
        // if (window.localStorage && useCached) {
        //     json = null;
        //     last_load = window.localStorage.getItem(url + '_last_load') || 0;
        //     if (last_load != null) {
        //         last_load = parseInt(last_load);
        //     }
        //     if (last_load && timestamp < last_load) {
        //         json = window.localStorage.getItem(url);
        //     }
        //     if (json) {
        //         attributeFiltersCallback(JSON.parse(json));
        //     } else {
        //         jQuery.getJSON(url, function(json) {
        //             window.localStorage.setItem(url, JSON.stringify(json));
        //             window.localStorage.setItem('attributes_last_load', (new Date).getTime() / 1000);
        //             return attributeFiltersCallback(json);
        //         });
        //     }
        // } else {
            jQuery.getJSON(url, function(json) {
                return attributeFiltersCallback(json);
            });
        // }
        jQuery(document).on('shown.bs.collapse', '#newAttributeFilter', function() {
            var attrSelect, i, key, len, ref, results, value;
            jQuery(this).find('select.scope').hide();
            jQuery(this).find('.value-input-container').empty();
            attrSelect = jQuery(this).find('select.attribute');
            attrSelect.html("<option>Select field name</option>");
            ref = window.sortedAttributeFilters;
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
                key = ref[i];
                value = key.value;
                if (value.scopes) {
                    results.push(attrSelect.append('<option value="' + key.key + '">' + value.label + '</option>'));
                } else {
                    results.push(void 0);
                }
            }
            return results;
        });

    });
};

jQuery.fn.searchDateRange = function(from, to) {
    return this.each(function() {
        var dateRangeOptions, fromInput, picker, toInput;
        dateRangeOptions = {
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
        fromInput = jQuery(this).find('.from');
        toInput = jQuery(this).find('.to');
        picker = jQuery(this).find('.picker');
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
