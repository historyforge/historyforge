import React, { useState } from 'react'
import { connect } from 'react-redux'
import { ButtonGroup } from 'reactstrap'
import YearButtons from './YearButtons'
import AddFilter from './AddFilter'
import Filters from './Filters'

import { load, setYear } from '../actions'

const CensusSearch = (props) => {
  const [open, setOpen] = useState(null)

  const { years, year, setYear, filters, current, message, params } = props

  const add = (value) => {
    props.addFilter(value)
    setOpen(value)
  }

  const remove = (value) => {
    props.removeFilter(value)
    setOpen(null)
    props.load()
  }

  const set = (field, predicate, criteria) => {
    props.setFilter(field, predicate, criteria)
  }

  const search = () => {
    setOpen(null)
    props.load()
  }

  return (
        <div className="pt-3 pb-1">
            <h3>Search HistoryForge</h3>
            <YearButtons years={years} year={year} setYear={setYear} />
            <AddFilter filters={filters} addFilter={add} />
            <Filters current={current}
                     setOpen={(key) => setOpen(key)}
                     open={open}
                     filters={filters}
                     close={() => setOpen(null)}
                     search={search}
                     setFilter={set}
                     remove={(key) => remove(key)}
            />
            {message && <div className="mt-2 alert alert-info">{message}</div>}
            {year && (
                <ButtonGroup className="btn-block">
                    <a href={buildCensusUrl(year, params)} className="btn btn-sm btn-info col-6">VIEW CENSUS RECORDS</a>
                    {/* <a href={this.demographicsUrl} className="btn btn-sm btn-info col-4">VIEW DEMOGRAPHICS</a> */}
                    <button className="btn btn-sm btn-info col-6" type="button" onClick={props.reset}>RESET</button>
                </ButtonGroup>
            )}
        </div>
  )
}

function buildCensusUrl(year, params) {
  let url = `/census/${year}`
  if (params) {
    const { f, s } = params
    url += `?${$.param({ f, s })}`
  }
  return url
}

// This is here until we build in "permission to see" to allow us
// to show the Demographics button conditionally.
// function buildDemographicsUrl(year, params) {
//     let url = `/census/${year}/demographics`
//     if (params) {
//         const {f, s} = params
//         url += `?${$.param({f, s, facet: 'race'})}`
//     }
//     return url;
// }

const mapStateToProps = state => {
  return { ...state.search, message: state.buildings.message }
}

const actions = {
  load,
  reset: () => ({ type: 'FORGE_RESET' }),
  setYear,
  addFilter: (filter) => ({ type: 'FORGE_ADD_FILTER', filter }),
  removeFilter: (filter) => ({ type: 'FORGE_REMOVE_FILTER', filter }),
  setFilter: (field, predicate, criteria) => ({ type: 'FORGE_SET_FILTER', field, predicate, criteria })
}

const Component = connect(mapStateToProps, actions)(CensusSearch)

export default Component
