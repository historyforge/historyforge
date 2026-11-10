import React from 'react'

export default function ScopeSelector({ field, predicate, criteria, config: { scopes }, handleChange }) {
  return Object.keys(scopes).map(scope => (
        <div className="form-check" key={scope}>
            <label className="form-check-label">
                <input className="form-check-input" type="radio"
                       name="predicate"
                       value={scope}
                       checked={predicate === scope}
                       onChange={() => handleChange(field, scope, criteria)}
                />
                {scopes[scope]}
            </label>
        </div>
  ))
}
