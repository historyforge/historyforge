import React, { useEffect, useState } from 'react'
import { useDispatch } from 'react-redux'
import ForgeModal from '../ForgeModal'
import PlaceView from '../PlaceView'

export const BuildingModal = ({ building }) => {
  const dispatch = useDispatch()
  const [title, setTitle] = useState('Loading place…')
  const [trail, setTrail] = useState([])
  useEffect(() => { setTrail(building ? [building.id] : []) }, [building?.id])
  return <ForgeModal open={!!building} onClose={() => dispatch({ type: 'BUILDING_DESELECT' })} title={title}>
    {trail.length > 1 && <button className="btn btn-light mb-3" onClick={() => setTrail(current => current.slice(0, -1))}>← Back to previous place</button>}
    {!!trail.length && <PlaceView onTitle={setTitle} key={trail[trail.length - 1]} id={trail[trail.length - 1]} onNavigate={path => setTrail(current => [...current, path.split('/').pop()])} />}
  </ForgeModal>
}
