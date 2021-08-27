import React from "react";

function getFilterText(predicate, criteria, config) {
    const { type, scopes } = config

    switch(type) {
        case 'boolean':
            return criteria && <span> ({criteria})</span>
        case 'checkboxes':
            if (!criteria) return ''

            const {choices} = config
            const output = choices
                .filter(choice => criteria.indexOf(choice[1]) > -1)
                .map(choice => choice[0])
                .join(', ')
            return criteria.length && <span> ({output})</span>
        case 'number':
        case 'text':
            return criteria && predicate && <span> {scopes[predicate]} {criteria}</span>
    }
}

export default class FilterListItem extends React.PureComponent {
    render() {
        const { setOpen, remove, config: { label }, predicate, criteria } = this.props
        return (
            <div className="list-group-item" onClick={setOpen}>
                <span className="float-right" onClick={remove}>&times;</span>
                {label}
                {getFilterText(predicate, criteria, this.props.config)}
            </div>
        )
    }
}
