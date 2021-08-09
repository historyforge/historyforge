import React, { useState } from 'react'
import {connect} from "react-redux";

const Search = (props: SearchData): JSX.Element => {
    const [term, setTerm] = useState('');
    const search = (event) => {
        const { target: { value } } = event;
        setTerm(value);
        props.search(value);
    }
    return (
        <div className="pt-3 pb-1">
            <h3>Search Name or Address</h3>
            <input className="form-control"
                   type="search"
                   value={term}
                   onChange={search} />
        </div>
    )
}

// Oddly enough doesn't need anything just a vehicle to hook up the search action
const mapStateToProps = _state => {
    return {}
}

const actions = {
    search: (term) => ({ type: 'SEARCH', term })
}

const Component = connect(mapStateToProps, actions)(Search)

export default Component
