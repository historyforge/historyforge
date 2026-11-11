import React from 'react'
import ScopeSelector from './ScopeSelector'
import isValuelessPredicate from '../../search/isValuelessPredicate'

export default function BasicField(props) {
  const { type, field, predicate, criteria, handleChange } = props
  const hasInput = !isValuelessPredicate(predicate)
  return (
        <div className="row">
            <div className="col-sm-6">
                <ScopeSelector {...props} />
            </div>
            <div className="col-sm-6">
                {hasInput && (
                    <input className="form-control" type={type}
                        name={field}
                        value={criteria || ''}
                        onChange={(e) => handleChange(field, predicate, e.target.value)} />
                 )}
            </div>
        </div>
  )
}
