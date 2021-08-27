import {FormGroup, Input, Label} from "reactstrap";
import React from "react";

export default function ScopeSelector(props) {
    const { field, predicate, criteria, config: { scopes }, handleChange } = props

    return Object.keys(scopes).map(scope => (
        <FormGroup key={scope} check>
            <Label check>
                <Input type="radio"
                       name="predicate"
                       value={scope}
                       checked={predicate === scope}
                       onChange={() => handleChange(field, scope, criteria)}
                />
                {scopes[scope]}
            </Label>
        </FormGroup>
    ))
}
