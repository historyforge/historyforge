import selectScope from './selectScope'

const selectAttribute = function(attribute: string, form: JQuery, config: AttributeFilterConfig) {
    const scopeSelect = buildScopeSelector(form, config)

    scopeSelect.on('change', function() {
        const $input = valueBox.find('input');
        const value = $(this).val().toString()
        if (value.match(/y_term/)) {
            $input.attr('placeholder', 'spaces separate "multiple words"');
        }
        if ($input.length === 1) {
            return $input.trigger('focus');
        }
    });

    const valueBox = form.find('.value-input-container');
    valueBox.hide().empty().prop('className', 'value-input-container col-6').addClass(config.type);
    if (config.columns) {
        valueBox.addClass('column-count-' + config.columns);
    }

    const addInput = function(input: HTMLElement): void {
        appendToValueBox(input, config.append, valueBox)
    }

    const scopeName = scopeSelect.val().toString();

    switch (config.type) {
        case 'boolean':
            return booleanInput(scopeName, addInput);
        case 'checkboxes':
            return checkboxesInput(scopeName, config.choices, valueBox);
        case 'text':
            return textInput(scopeName, addInput);
        case 'number':
        case 'age':
        case 'time':
            return numberInput(scopeName, scopeSelect, addInput);
        case 'dropdown':
            return dropdownInput(scopeName, config.choices, addInput);
    }
};

function booleanInput(scopeName: string, addInput: AddInputFn): void {
    const input = document.createElement('INPUT');
    input.setAttribute('name', `s[${scopeName}]`);
    input.setAttribute('type', 'hidden');
    input.setAttribute('value', '1');
    addInput(input);
}

function checkboxInput(choice: ChoiceValue, scopeName: string, valueBox: JQuery): void {
    let labelText, value;
    if (typeof choice === 'string') {
        labelText = value = choice;
    } else {
        [labelText, value] = choice;
    }

    const name = `s[${scopeName}][]`;
    const id = `s_${scopeName}_${value}`;
    const checkbox = document.createElement('DIV');
    checkbox.classList.add('form-check');
    const input = document.createElement('INPUT');
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
}

function checkboxesInput(scopeName: string, choices: Choices, valueBox: JQuery): void {
    const null_choice = document.createElement('INPUT');
    null_choice.setAttribute('type','hidden');
    null_choice.setAttribute('disabled', 'true');
    null_choice.setAttribute('value', '1')
    null_choice.className = 'null-choice';
    valueBox.append(null_choice);
    choices.forEach((choice) => {
        checkboxInput(choice, scopeName, valueBox);
    })
    valueBox.css('display', 'inline');
}

function textInput(scopeName: string, addInput: AddInputFn) {
    const input = document.createElement('INPUT');
    input.classList.add('form-control');
    input.setAttribute('name', `s[${scopeName}]`);
    input.setAttribute('type', 'text');
    addInput(input);
}

function numberInput(scopeName: string, scopeSelect: JQuery, addInput: AddInputFn): void {
    const input = document.createElement('INPUT');
    input.classList.add('form-control');
    input.setAttribute('name', `s[${scopeName}]`);
    input.setAttribute('type', 'number');
    addInput(input);
    scopeSelect.on('change', function() {
        const val = jQuery(this).val().toString();
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
}

function dropdownInput(scopeName: string, choices: Choices, addInput: AddInputFn): void {
    const input = document.createElement('SELECT');
    input.classList.add('form-control');
    input.setAttribute('name', `s[${scopeName}]`);
    choices.forEach((choice) => {
        if (typeof choice !== 'string') return;

        const option = document.createElement('OPTION');
        option.setAttribute('value', choice);
        option.innerText = choice;
        input.appendChild(option);
    })
    addInput(input);
}

function buildScopeSelector(form: JQuery, config: AttributeFilterConfig): JQuery {
    const container = form.find('.scope-selection-container').empty().hide();
    const scopeSelect = $('<select class="scope form-control"></select>');
    scopeSelect.on('change', selectScope)
    for (let key in config.scopes) {
        const value = config.scopes[key];
        scopeSelect.append(`<option value="${key}" ">${value}</option>`);
    }
    scopeSelect.find('option:first').prop('selected', true);
    if (scopeSelect.find('option').length === 1) {
        scopeSelect.hide();
        container.append($('<span>' + scopeSelect.find('option:first').text() + '</span>'));
    }
    container.append(scopeSelect).css('display', 'inline');
    return scopeSelect;
}

function appendToValueBox(input: HTMLElement, append: string, valueBox: JQuery): void {
    if (append) {
        const div = document.createElement('DIV');
        div.className = 'input-append';
        const span = document.createElement('SPAN');
        span.className = 'add-on';
        span.appendChild(document.createTextNode(append));
        div.appendChild(input);
        div.appendChild(span);
        valueBox.append(div);
    } else {
        valueBox.append(input);
    }
    valueBox.css('display', 'inline');
}

export default selectAttribute;
