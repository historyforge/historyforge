import React from 'react'
import { highlight as highlightBuilding } from '../forge/actions'
import {useAppDispatch, useAppSelector} from "../forge/hooks";

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


export const Buildings = () => {
  const dispatch = useAppDispatch();
  const props = useAppSelector(state => ({ ...state.buildings }));
  const { buildings, highlighted } = props;
  const highlight = (building) => dispatch(highlightBuilding(building.id));

  return buildings ? (
    <div id="building-list">
      <h3>Nearby Buildings</h3>
      <div className="list-group">
        {buildings.map((building, i) => (
          <Building key={i} {...building} highlighted={highlighted} highlight={highlight} />
        ))}
      </div>
    </div>
  ) : null
}
