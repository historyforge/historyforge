import React from 'react'
import {connect} from "react-redux";
import SimpleFormat from '../forge/SimpleFormat'

class Building extends React.PureComponent {
    render() {
        const { id, street_address } = this.props
        return(
            <div className={`list-group-item building ${this.highlighted && 'active'}`}>
                <p>
                    <a href={`/buildings/${ id }`} target="_blank"
                       title="Open building record in new tab">
                        {street_address}
                    </a>
                </p>
            </div>
        )
    }

    get highlighted() {
        return this.props.highlighted === this.props.id
    }
}
class Buildings extends React.PureComponent {
    render() {
        const {buildings, highlighted} = this.props
        if (!buildings) return

        return (
            <div id="building-list">
                <h3>Nearby Buildings</h3>
                <div className="list-group">
                    {buildings.map((building, i) => (
                        <Building key={i} {...building.data.attributes} highlighted={highlighted} />
                    ))}
                </div>
            </div>
        )
    }
}

const mapStateToProps = state => {
    return {...state.buildings}
}

const actions = {
}

const Component = connect(mapStateToProps, actions)(Buildings)

export default Component
