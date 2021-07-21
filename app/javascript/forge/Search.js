import React from 'react'
import {connect} from "react-redux";

class Search extends React.PureComponent {
    state = { term: '' }
    render() {
        const { term } = this.state

        return (
            <div className="pt-3 pb-1">
                <h3>Search Name or Address</h3>
                <input className="form-control"
                       type="search"
                       value={term}
                       onChange={(e) => this.search(e.target.value) } />
            </div>
        )
    }

    search(term) {
        this.setState({ term })

        this.props.search(term)
    }
}

const mapStateToProps = state => {
    if (state.buildings.buildings) {
        return { buildings: state.buildings.buildings }
    } else {
        return { buildings: [] }
    }
}

const actions = {
    search: (term) => ({ type: 'SEARCH', term })
}

const Component = connect(mapStateToProps, actions)(Search)

export default Component
