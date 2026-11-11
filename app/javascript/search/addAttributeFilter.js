import isValuelessPredicate from './isValuelessPredicate'

class AttributeFilter {
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
        const closeButton = document.createElement('button')
        closeButton.type = 'button'
        closeButton.className = 'btn-close remove-filter'
        closeButton.setAttribute('aria-label', `Remove ${this.config.label} filter`)
        this.html.append(closeButton, this.sentence.join(' '), this.config.append || '')
    }

    renderInput() {
        if (isValuelessPredicate(this.scope)) {
            this.renderBoolean();
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
        this.sentence.push(selection ?? this.scopeValue)
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
}

export default function addAttributeFilter(container, form, config, scope, value) {
    const filter = new AttributeFilter(config, scope, value).render()
    container.append(filter)
    filter.querySelector('button').addEventListener('click', () => {
        const name = `s[${scope}]`
        const names = [name, name + '[]', name.replace('_in', '_eq')]
        for (const field of form.elements) {
            if (names.includes(field.name)) field.value = ''
        }
        filter.remove()
        form.requestSubmit()
    })
}
