// import {IAttributeFilter, AttributeFilterConfig, ScopeValue} from "./types";

class AttributeFilter implements IAttributeFilter {
    html = document.createElement('DIV');
    input = document.createElement('INPUT');
    config; scope; scopeValue; sentence;

    constructor(config, scope, scopeValue) {
        Object.assign(this, { config, scope, scopeValue })
        this.sentence = [this.config.label];
    }

    render() {
        ['attribute-filter', 'btn', 'btn-sm', 'btn-light'].forEach((text) => {
            this.html.classList.add(text)
        })

        this.input.setAttribute('type', 'hidden');
        this.input.setAttribute('name', `s[${this.scope}]`);


        for (let key in this.config.scopes) {
            const value = this.config.scopes[key];
            if (key === this.scope) {
                this.sentence.push(value);
            }
        }
        this.renderInput();
        this.renderLabel();
        return this.html;
    }

    renderLabel() {
        const closeButton: HTMLElement = document.createElement('BUTTON');
        closeButton.setAttribute('type', 'button');
        closeButton.classList.add('close');
        closeButton.classList.add('remove-filter');
        closeButton.innerHTML = "&times;";

        const desc = document.createElement('SPAN');
        desc.appendChild(closeButton);
        desc.innerHTML += this.sentence.join(' ');
        if (this.config.append) {
            desc.innerHTML += this.config.append;
        }
        this.html.appendChild(desc);
        this.html.addEventListener('click', function() {
            const $filter = $(this).closest('.attribute-filter')
            const name = $filter.find('input:first').attr('name')

            $(`[name="${name}"]`).val(null)
            $(`[name="${name.replace('[]', '')}"]`).val(null)
            $(`[name="${name.replace('_in', '_eq')}"]`).val(null)

            $filter.remove();
            $('#new_s').trigger('submit');
        });
    }

    renderInput() {
        if (this.scope.match(/null$/)) {
            this.renderNullInput();
        } else {
            switch (this.config.type) {
                case 'boolean':
                    return this.renderBoolean();
                case 'checkboxes':
                    return this.renderCheckboxes();
                case 'text':
                    return this.renderText();
                case 'number':
                    return this.renderNumber();
                case 'dropdown':
                    return this.renderDropdown();
            }
        }
    }

    renderDropdown() {
        this.input.setAttribute('value', this.scopeValue);
        this.html.appendChild(this.input);

        const selection = this.config.choices.find((choice) => this.scopeValue === choice.toString())
        this.sentence.push(selection.toString())
    }

    renderNumber() {
        this.input.setAttribute('value', this.scopeValue);
        this.html.appendChild(this.input);
        this.sentence.push(this.scopeValue);
    }

    renderText() {
        this.input.setAttribute('value', this.scopeValue);
        this.html.appendChild(this.input);
        this.sentence.push(`"${this.scopeValue}"`)
    }

    renderCheckboxes() {
        const values = [];
        this.config.choices.forEach((choice) => {
            let label, value;
            if (typeof choice === 'string') {
                label = value = choice;
            } else {
                [label, value] = choice;
            }
            const scopeValue = (typeof this.scopeValue === 'string') ? [this.scopeValue] : this.scopeValue;
            scopeValue.forEach((singleScopeValue) => {
                if (value.toString() === singleScopeValue.toString()) {
                    values.push(label);
                    let multiInput = document.createElement('INPUT');
                    multiInput.setAttribute('type', 'hidden');
                    multiInput.setAttribute('name', `s[${this.scope}][]`);
                    multiInput.setAttribute('value', singleScopeValue);
                    this.html.appendChild(multiInput);
                }
            })
        })
        this.sentence.push(values.join(', '));
    }

    renderBoolean() {
        this.input.setAttribute('value', '1');
        this.html.appendChild(this.input);
    }

    renderNullInput() {
        this.input.setAttribute('value', '1');
        this.html.appendChild(this.input);
    }
}

const addAttributeFilter = function(field_config: AttributeFilterConfig, scope: string, scopeValue: ScopeValue) {
    const filter = new AttributeFilter(field_config, scope, scopeValue);
    filter.render();
    $('#attribute-filters').append(filter.html);
};

export default addAttributeFilter;
