import React from 'react'
import { connect } from 'react-redux'
import { highlight } from '../forge/actions'

const Building = ({ id, street_address, highlight, highlighted }) => (
    <div className={`list-group-item building ${highlighted === id && 'active'}`}
        onMouseOver={() => highlight(id)}
        onMouseOut={() => highlight(null)}>
        <p>
            <a href={`/buildings/${id}`}
               title="Open building record">
                {street_address}
            </a>
        </p>
    </div>
)


const Buildings = ({ buildings, highlighted, highlight }) => (buildings ? (
    <div id="building-list">
        <h3>Nearby Buildings</h3>
        <div className="list-group">
            {buildings.map((building, i) => (
                <Building key={i} {...building} highlighted={highlighted} highlight={highlight} />
            ))}
        </div>
    </div>
) : null)


const mapStateToProps = state => {
  return { ...state.buildings }
}

const actions = { highlight }

const Component = connect(mapStateToProps, actions)(Buildings)

export default Component
