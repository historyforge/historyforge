import React, { useState } from 'react'
import {connect} from "react-redux";
import {Modal, ModalBody, ModalHeader, ModalFooter, ButtonGroup} from "reactstrap";
import FilterField from "./census-search/FilterField";
import FilterListItem from "./census-search/FilterListItem";

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
                    <ButtonGroup className="btn-block">
                        <a href={this.url} className="btn btn-sm btn-info col-4">VIEW CENSUS RECORDS</a>
                        <a href={this.demographicsUrl} className="btn btn-sm btn-info col-4">VIEW DEMOGRAPHICS</a>
                        <button className="btn btn-sm btn-info col-4" type="button" onClick={this.reset.bind(this)}>RESET</button>
                    </ButtonGroup>
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

    reset() {
        this.props.reset()
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
    reset: () => ({type: 'FORGE_RESET'}),
    setYear: (year) => ({ type: 'FORGE_SET_YEAR', year }),
    addFilter: (filter) => ({ type: 'FORGE_ADD_FILTER', filter }),
    removeFilter: (filter) => ({ type: 'FORGE_REMOVE_FILTER', filter }),
    setFilter: (field, predicate, criteria) => ({ type: 'FORGE_SET_FILTER', field, predicate, criteria })
}

const Component = connect(mapStateToProps, actions)(CensusSearch)

export default Component
