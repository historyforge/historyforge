import { Col, Input, Row } from 'reactstrap'
import React from 'react'
import ScopeSelector from './ScopeSelector'

export default function BasicField(props) {
  const { type, field, predicate, criteria, handleChange } = props
  return (
        <Row>
            <Col sm={6}>
                <ScopeSelector {...props} />
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
