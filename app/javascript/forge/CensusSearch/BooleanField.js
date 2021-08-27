import {FormGroup, Input, Label} from "reactstrap";
import React from "react";

export default function BooleanField(props) {
    const { field, predicate, config: { scopes }, handleChange } = props
    return Object.keys(scopes).map(scope => (
        <FormGroup key={scope} check>
            <Label check>
                <Input type="radio"
                       name={field}
                       value={scope}
                       checked={predicate === scope}
                       onChange={() => handleChange(field, scope, scopes[scope])}
                />
                {scopes[scope]}
            </Label>
        </FormGroup>
    ))
}
