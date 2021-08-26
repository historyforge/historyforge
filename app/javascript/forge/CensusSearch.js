import React, { useState } from 'react'
import {connect} from "react-redux";
import {Modal, ModalBody, ModalHeader, ModalFooter, Row, Col, FormGroup, Label, Input} from "reactstrap";

function getFilterText(predicate, criteria, config) {
    const { type, scopes } = config

    switch(type) {
        case 'boolean':
            return criteria && <span> ({criteria})</span>
        case 'checkboxes':
            if (!criteria) return ''

            const {choices} = config
            const output = choices
                .filter(choice => criteria.indexOf(choice[1]) > -1)
                .map(choice => choice[0])
                .join(', ')
            return criteria.length && <span> ({output})</span>
        case 'number':
        case 'text':
            return criteria && predicate && <span> {scopes[predicate]} {criteria}</span>
    }
}

class FilterListItem extends React.PureComponent {
    render() {
        const { setOpen, remove, config: { label }, predicate, criteria } = this.props
        return (
            <div className="list-group-item" onClick={setOpen}>
                <span className="float-right" onClick={remove}>&times;</span>
                {label}
                {getFilterText(predicate, criteria, this.props.config)}
            </div>
        )
    }
}

const BooleanField = props => {
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

class ListField extends React.PureComponent {
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

const BasicField = props => {
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

const NumberField = props => {
    const { field, predicate, criteria, config: { scopes }, handleChange } = props
    return <BasicField type={'number'}
                       field={field}
                       predicate={predicate}
                       criteria={criteria}
                       scopes={scopes}
                       handleChange={handleChange} />
}

const TextField = props => {
    const { field, predicate, criteria, config: { scopes }, handleChange } = props
    return <BasicField type={'text'}
                       field={field}
                       predicate={predicate}
                       criteria={criteria}
                       scopes={scopes}
                       handleChange={handleChange} />
}

const FilterField = props => {
    const { config: { type } } = props
    switch(type) {
        case 'boolean': return <BooleanField {...props} />
        case 'checkboxes': return <ListField {...props} />
        case 'number': return <NumberField {...props} />
        case 'text': return <TextField {...props} />
        default: return null
    }
}

class CensusSearch extends React.PureComponent {
    state = { open: null, filter: '' }

    render() {
        const { years, year, setYear, filters, current, message } = this.props
        const { open, filter } = this.state
        return (
            <div className="pt-3 pb-1">
                <h3>Census Search</h3>
                <div className="btn-group btn-block">
                    {years.map(censusYear => (
                        <button type="button"
                                key={censusYear}
                                className={`btn btn-${censusYear === year ? 'primary' : 'light'}`}
                                onClick={() => { setYear(censusYear) } }>
                            {censusYear}
                        </button>
                    ))}
                </div>
                { filters && (
                    <select value={filter} onChange={this.addFilter.bind(this)} className="form-control">
                        <option value={null}>Select a field to search</option>
                        {Object.keys(filters).map(key => (
                            filters[key].type && <option key={key} value={key}>{filters[key].label}</option>
                        ))}
                    </select>
                )}
                {current && (
                    <div className="list-group">
                        {Object.keys(current).map(key => (
                            <FilterListItem key={key}
                                            {...current[key]}
                                            config={filters[key]}
                                            setOpen={() => this.setState({ open: key })}
                                            remove={(e) => { e.stopPropagation(); this.removeFilter(key) }}
                            />
                        ))}
                    </div>
                )}
                {message && <div className="mt-2 alert alert-info">
                    {message}
                </div>}
                {year && (
                    <Row>
                        <Col md={6}>
                            <a href={this.url} className="float-right btn btn-info btn-block">VIEW RECORDS</a>
                        </Col>
                        <Col md={6}>
                            <a href={this.demographicsUrl} className="float-right btn btn-info btn-block">EAT PIE</a>                        </Col>
                    </Row>
                )}
                <Modal isOpen={!!open}>
                    <ModalHeader toggle={() => this.setState({ open: null })}>
                        Search on &ldquo;{open && filters[open].label}&rdquo;
                    </ModalHeader>
                    <ModalBody>
                        {open && <FilterField {...current[open]} config={filters[open]} handleChange={this.setFilter.bind(this)} />}
                    </ModalBody>
                    <ModalFooter>
                        <button className="btn btn-primary" type="button" onClick={this.search.bind(this)}>Search</button>
                    </ModalFooter>
                </Modal>

            </div>
        )
    }

    addFilter(event) {
        const value = event.target.value
        this.props.addFilter(value)
        this.setState({ open: value })
    }

    removeFilter(filter) {
        this.props.removeFilter(filter)
        this.setState({ open: null })
        this.props.load(this.props.params)
    }

    setFilter(field, predicate, criteria) {
        this.props.setFilter(field, predicate, criteria)
    }

    search() {
        this.setState({open: null})
        this.props.load(this.props.params)
    }

    componentDidUpdate(prevProps, prevState, snapshot) {
        if (prevProps.year !== this.props.year) {
            this.props.load(this.props.params)
        }
    }

    get url() {
        const {year} = this.props
        let url = `/census/${year}`
        if (this.props.params) {
            const {f, s} = this.props.params
            url += `?${$.param({f, s})}`
        }
        return url
    }

    get demographicsUrl() {
        const {year} = this.props
        let url = `/census/${year}/demographics`
        if (this.props.params) {
            const {f, s} = this.props.params
            url += `?${$.param({f, s, facet: 'race'})}`
        }
        return url
    }
}

const mapStateToProps = state => {
    return {...state.search, message: state.buildings.message}
}

const actions = {
    load: (params) => ({type: 'BUILDING_LOAD', params}),
    setYear: (year) => ({ type: 'FORGE_SET_YEAR', year }),
    addFilter: (filter) => ({ type: 'FORGE_ADD_FILTER', filter }),
    removeFilter: (filter) => ({ type: 'FORGE_REMOVE_FILTER', filter }),
    setFilter: (field, predicate, criteria) => ({ type: 'FORGE_SET_FILTER', field, predicate, criteria })
}

const Component = connect(mapStateToProps, actions)(CensusSearch)

export default Component
