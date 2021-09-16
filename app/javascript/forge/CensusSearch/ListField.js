import React from 'react'
import { Col, FormGroup, Input, Label, Row } from 'reactstrap'
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
        <Row>
            <Col sm={6}>
                <ScopeSelector {...props} />
            </Col>
            <Col sm={6}>
                {choices.map(choice => (
                    <FormGroup key={choice[1]} check>
                        <Label check>
                            <Input type="checkbox"
                                   name={`${field}-${choice[1]}`}
                                   checked={criteria.indexOf(choice[1]) > -1}
                                   onChange={() => choose(props, choice[1])}
                            />
                            {choice[0]}
                        </Label>
                    </FormGroup>
                ))}
            </Col>
        </Row>
  )
}

export default ListField
