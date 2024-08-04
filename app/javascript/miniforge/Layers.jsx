import React from 'react'
import { connect } from 'react-redux'
import {useAppDispatch, useAppSelector} from "../forge/hooks";

export const Layers = () => {
  const dispatch = useAppDispatch();
  const { layers, layer, opacity } = useAppSelector(state => ({ ...state.layers }));

  if (!layers || !layers.length) return null;

  const setOpacity = (opacity) => dispatch({ type: 'LAYER_OPACITY', opacity });
  const toggle = (id) => dispatch({ type: 'LAYER_TOGGLE', id });

  const handleChange = (event) => {
    const value = parseInt(event.currentTarget.value)
    const layer = layers.find(l => l.id === value)
    dispatch(toggle(layer?.id));
  }

  return (
    <div>
        <input type="range"
               min={0}
               max={100}
               value={opacity > -1 ? opacity : 100}
               onChange={(e) => setOpacity(e.target.value)} />
        <select className="form-control" value={layer?.id} onChange={handleChange}>
          <option value={null}>No historic map</option>
          {layers.map(l => <option key={l.id} value={l.id}>{l.name}</option>)}
        </select>
    </div>
  )
}
