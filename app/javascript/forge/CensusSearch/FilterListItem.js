import React from 'react'

function getFilterText(predicate, criteria, config) {
  const { type, scopes } = config

  switch (type) {
    case 'boolean':
      return criteria && <span> ({criteria ? 'Yes' : 'No'})</span>
    case 'checkboxes':
      if (!criteria) return ''

      const { choices } = config
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

const FilterListItem = props => {
  const { setOpen, remove, config: { label }, predicate, criteria } = props
  if (!criteria.length) return null

  return (
        <div className="list-group-item" onClick={setOpen}>
            <span className="float-right" onClick={remove}>&times;</span>
            {label}
            {getFilterText(predicate, criteria, props.config)}
        </div>
  )
}

export default FilterListItem
