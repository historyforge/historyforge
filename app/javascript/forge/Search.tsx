import React, { useState } from 'react'
import { connect } from 'react-redux'
import { searchTerm } from './actions'

const Search = (props: SearchData): JSX.Element => {
  const [term, setTerm] = useState('')

  const change = (event) => {
    const { target: { value } } = event
    setTerm(value)
  }
  const search = (event) => {
    const { keyCode } = event
    if (keyCode === 13) {
      props.search(term)
    }
  }
  return (
        <div className="pt-3 pb-1">
            <h3>Search Name or Address</h3>
            <input className="form-control"
                   type="search"
                   value={term}
                   onKeyUp={search}
                   onChange={change} />
        </div>
  )
}

// Oddly enough doesn't need anything just a vehicle to hook up the search action
const mapStateToProps = _state => {
  return {}
}

const actions = {
  search: (term) => searchTerm(term)
}

const Component = connect(mapStateToProps, actions)(Search)

export default Component
