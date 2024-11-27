import React from 'react'
import { highlight } from '../forge/actions'
import {useDispatch, useSelector} from "react-redux";

const Building = ({ id, street_address, highlighted }) => {
  const dispatch = useDispatch();
  return (
    <div className={`list-group-item building ${highlighted === id && 'active'}`}
         onMouseOver={() => dispatch(highlight(id))}
         onMouseOut={() => dispatch(highlight(null))}>
      <p>
        <a href={`/buildings/${id}`}
           title="Open building record">
          {street_address}
        </a>
      </p>
    </div>
  )
}


export const Buildings = () => {
  const props = useSelector(state => ({ ...state.buildings }));
  const { buildings, highlighted } = props;
  return buildings ? (
    <div id="building-list">
      <h3>Nearby Buildings</h3>
      <div className="list-group">
        {buildings.map((building, i) => (
          <Building key={i} {...building} highlighted={highlighted} />
        ))}
      </div>
    </div>
  ) : null
}
