import React from 'react'
import ScopeSelector from './ScopeSelector'

export default function BasicField(props) {
  const { type, field, predicate, criteria, handleChange } = props
  console.log(predicate)
  const hasInput = !predicate.match(/null$/);
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
