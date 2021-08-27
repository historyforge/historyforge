import React from "react";
import {Col, FormGroup, Input, Label, Row} from "reactstrap";

export default class ListField extends React.PureComponent {
    choose(value) {
        const { criteria, field, predicate, handleChange } = this.props
        const nextCriteria = criteria ? [...criteria] : []
        const idx = nextCriteria.indexOf(value)
        if (idx === -1) {
            nextCriteria.push(value)
        } else {
            nextCriteria.splice(idx, 1)
        }
        handleChange(field, predicate, nextCriteria)
    }

    render() {
        const { field, predicate, config: { scopes, choices }, handleChange } = this.props
        const criteria = this.props.criteria || [] // to avoid changing uncontrolled to controlled component
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
                    {choices.map(choice => (
                        <FormGroup key={choice[1]} check>
                            <Label check>
                                <Input type="checkbox"
                                       name={`${field}-${choice[1]}`}
                                       checked={criteria.indexOf(choice[1]) > -1}
                                       onChange={() => this.choose(choice[1])}
                                />
                                {choice[0]}
                            </Label>
                        </FormGroup>
                    ))}
                </Col>
            </Row>
        )
    }
}
