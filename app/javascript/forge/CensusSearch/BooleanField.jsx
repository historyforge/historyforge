import React from 'react'

export default function BooleanField({ field, predicate, config: { scopes }, handleChange }) {
  React.useEffect(() => {
    const scope = Object.keys(scopes)[0]
    handleChange(field, scope, scopes[scope])
  }, []);
  return Object.keys(scopes).map(scope => (
        <div className="form-check" key={scope}>
            <label className="form-check-label">
                <input className="form-check-input" type="radio"
                       name={field}
                       value={scope}
                       checked={predicate === scope}
                       onChange={() => handleChange(field, scope, scopes[scope])}
                />
                {scopes[scope]}
            </label>
        </div>
  ))
}
