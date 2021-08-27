import {Col, FormGroup, Input, Label, Row} from "reactstrap";
import React from "react";

export default function BasicField(props) {
    const { type, field, predicate, criteria, scopes, handleChange } = props
    return (
        <Row>
            <Col sm={6}>
                {Object.keys(scopes).map(scope => (
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
                ))}
            </Col>
            <Col sm={6}>
                <Input type={type}
                       name={field}
                       value={criteria || ''}
                       onChange={(e) => handleChange(field, predicate, e.target.value)} />
            </Col>
        </Row>
    )
}
