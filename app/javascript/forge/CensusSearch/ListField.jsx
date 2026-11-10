import React from 'react'
import ScopeSelector from './ScopeSelector'

const choose = function (props, value) {
  const { criteria, field, predicate, handleChange } = props
  const nextCriteria = criteria ? [...criteria] : []
  const idx = nextCriteria.indexOf(value)
  if (idx === -1) {
    nextCriteria.push(value)
  } else {
    nextCriteria.splice(idx, 1)
  }
  handleChange(field, predicate, nextCriteria)
}

const ListField = (props) => {
  const { field, config: { choices } } = props
  const criteria = props.criteria || [] // to avoid changing uncontrolled to controlled component

  return (
        <div className="row">
            <div className="col-sm-6">
                <ScopeSelector {...props} />
            </div>
            <div className="col-sm-6">
                {choices.map(choice => (
                    <div className="form-check" key={choice[1]}>
                        <label className="form-check-label">
                            <input className="form-check-input" type="checkbox"
                                   name={`${field}-${choice[1]}`}
                                   checked={criteria.indexOf(choice[1]) > -1}
                                   onChange={() => choose(props, choice[1])}
                            />
                            {choice[0]}
                        </label>
                    </div>
                ))}
            </div>
        </div>
  )
}

export default ListField
