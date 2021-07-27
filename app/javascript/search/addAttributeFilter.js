class AttributeFilter {
    constructor(config, scope, scopeValue) {
        this.config = config;
        this.scope = scope;
        this.scopeValue = scopeValue;
    }

    render() {
        this.html = document.createElement('DIV');
        ['attribute-filter', 'btn', 'btn-sm', 'btn-light'].forEach((text) => {
            this.html.classList.add(text)
        })

        this.input = document.createElement('INPUT');
        this.input.setAttribute('type', 'hidden');
        this.input.setAttribute('name', `s[${this.scope}]`);

        this.sentence = [this.config.label];

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
        const closeButton = document.createElement('BUTTON');
        closeButton.type = 'button';
        closeButton.classList.add('close');
        closeButton.classList.add('remove-filter');
        closeButton.innerHTML = "&times;";

        const desc = document.createElement('SPAN');
        desc.appendChild(closeButton);
        desc.innerHTML += this.sentence.join(' ');
        if (this.config.append) {
            desc.innerHTML += config.append;
        }
        this.html.appendChild(desc);
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

        this.config.choices.forEach((choice) => {
            if (this.scopeValue === choice.toString()) {
                this.sentence.push(choice);
            }
        })
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
            this.scopeValue.forEach((singleScopeValue) => {
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

const addAttributeFilter = function(field_config, scope, scopeValue) {
    const filter = new AttributeFilter(field_config, scope, scopeValue);
    filter.render();
    $('#attribute-filters').append(filter.html);
};

export default addAttributeFilter;
