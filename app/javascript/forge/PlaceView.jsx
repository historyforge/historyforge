import React, { useEffect, useState } from 'react'
import { useDispatch } from 'react-redux'
import axios from 'axios'
import { Residents } from './Building/Residents'

export default function PlaceView({ id, onNavigate, onTitle }) {
  const dispatch = useDispatch()
  const [tab, setTab] = useState('History')
  useEffect(() => { setTab('History') }, [id])
  const [place, setPlace] = useState(null)
  const [error, setError] = useState(false)
  const [attempt, setAttempt] = useState(0)
  useEffect(() => {
    let active = true
    setPlace(null); setError(false)
    Promise.all([axios.get(`/forge/buildings/${id}/photographs`), axios.get(`/buildings/${id}.json`)])
      .then(([photos, building]) => { if (active) setPlace({ ...building.data, ...photos.data }) })
      .catch(() => { if (active) setError(true) })
    return () => { active = false }
  }, [id, attempt])
  useEffect(() => {
    if (place) dispatch({ type: 'PLACE_FOCUSED', place })
    return () => { dispatch({ type: 'PLACE_FOCUSED', place: null }) }
  }, [place, dispatch])
  useEffect(() => { onTitle?.(place?.address || 'Loading place…') }, [place, onTitle])
  if (error) return <p role="alert">This place couldn’t be loaded. <button className="btn btn-light" onClick={() => setAttempt(attempt + 1)}>Try again</button></p>
  if (!place) return <p role="status">Opening this place…</p>
  const photo = place.photos[0]
  const residents = place.census_records || {}
  const years = Object.keys(residents).filter(year => residents[year]?.some(household => household?.length)).sort()
  const tabs = [...(place.description?.trim() ? ['History'] : []), ...(years.length ? ['Residents'] : []), 'Nearby']
  const activeTab = tabs.includes(tab) ? tab : tabs[0]
  const showPhotos = () => dispatch({ type: 'PHOTO_BUILDING_SELECTED', id: place.id })
  return <article className="forge-place" key={id}>
    <div className="forge-place-intro">
      {photo && <button className={`forge-place-hero${place.photos.length === 1 ? ' forge-place-hero-single' : ''}`} onClick={showPhotos}
        aria-label={place.photos.length === 1 ? `View larger image of ${place.address}` : `View ${place.photos.length} photographs of ${place.address}`}>
        <img src={photo.image} alt={photo.caption || place.address} />
        {place.photos.length > 1 && <span><i className="fa fa-camera" aria-hidden="true" /> View {place.photos.length} photographs <span aria-hidden="true">→</span></span>}
      </button>}
      <div className="forge-place-story">
        <p className="forge-place-context">{[place.type, place.year_earliest && `Built ${place.year_earliest}`, place.year_latest && `Demolished ${place.year_latest}`].filter(Boolean).join(' · ')}</p>
        <div className="forge-place-tabs" role="tablist" aria-label="About this place">
          {tabs.map((name, index) => <button key={name} type="button"
            role="tab" id={`place-${id}-tab-${name}`} aria-controls={`place-${id}-panel-${name}`}
            aria-selected={activeTab === name} tabIndex={activeTab === name ? 0 : -1}
            onClick={() => setTab(name)} onKeyDown={event => {
              const names = tabs
              const next = event.key === 'ArrowRight' ? (index + 1) % names.length : event.key === 'ArrowLeft' ? (index + names.length - 1) % names.length : event.key === 'Home' ? 0 : event.key === 'End' ? names.length - 1 : null
              if (next === null) return
              event.preventDefault(); setTab(names[next])
              event.currentTarget.parentElement.children[next].focus()
            }}>{name}</button>)}
        </div>
        <section role="tabpanel" id={`place-${id}-panel-${activeTab}`} aria-labelledby={`place-${id}-tab-${activeTab}`} tabIndex={0} className="forge-place-panel">
          {activeTab === 'History' && <>
            <div className="forge-place-description">
              <p className="forge-photo-description">{place.description}</p>
              {place.architects && <p>Designed by {place.architects}.</p>}
            </div>
          </>}
          {activeTab === 'Residents' && <div className="forge-place-residents">
            <h2>Who lived here</h2>
            {years.length === 1 ? <Residents buildingId={id} residents={residents} years={years} /> : years.map(year => <details key={year}><summary>{year} census</summary><Residents buildingId={id} residents={residents} years={[year]} /></details>)}
          </div>}
          {activeTab === 'Nearby' && <div className="forge-place-nearby">
            <h2>Keep exploring nearby</h2>
            {!place.nearby?.length && <p>No nearby places are available.</p>}
            <div>{place.nearby?.map(neighbor => <button key={neighbor.id} onClick={() => onNavigate(`/buildings/${neighbor.id}`)}>
              <span>{neighbor.address}</span><span aria-hidden="true">→</span>
            </button>)}</div>
          </div>}
        </section>
      </div>
    </div>
  </article>
}
