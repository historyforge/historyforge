import React, { useEffect, useState } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import axios from 'axios'
import ForgeModal from './ForgeModal'

export default function PhotoGallery() {
  const id = useSelector(state => state.buildings.photoBuildingId)
  const dispatch = useDispatch()
  const [gallery, setGallery] = useState(null)
  const [selected, setSelected] = useState(null)
  const [error, setError] = useState(false)
  const [attempt, setAttempt] = useState(0)

  useEffect(() => {
    let active = true
    setGallery(null)
    setSelected(null)
    setError(false)
    if (id) axios.get(`/forge/buildings/${id}/photographs`).then(({ data }) => {
      if (!active) return
      setGallery(data)
      if (data.photos.length === 1) setSelected(0)
    }).catch(() => { if (active) setError(true) })
    return () => { active = false }
  }, [id, attempt])

  const photo = gallery?.photos[selected]
  return <ForgeModal open={!!id} onClose={() => dispatch({ type: 'PHOTO_BUILDING_DESELECT' })}
    title={gallery ? `Photographs: ${gallery.address}` : 'Photographs'} size="xl">
    {error ? <div role="alert">Unable to load photographs. <button type="button" className="btn btn-light" onClick={() => setAttempt(attempt + 1)}>Try again</button></div>
      : !gallery ? <p role="status">Loading photographs…</p> : <>
        <p><a href={gallery.url}>Open building record</a> · {gallery.photos.length} photograph{gallery.photos.length === 1 ? '' : 's'}</p>
        {!gallery.photos.length && <p>No photographs are available for this building.</p>}
        {photo && <section className="forge-photo-viewer" aria-label="Selected photograph">
          <div className="d-flex justify-content-between align-items-center mb-2">
            <button type="button" className="btn btn-light" disabled={selected === 0} onClick={() => setSelected(selected - 1)}>Previous</button>
            <span aria-live="polite">{selected + 1} of {gallery.photos.length}</span>
            <button type="button" className="btn btn-light" disabled={selected === gallery.photos.length - 1} onClick={() => setSelected(selected + 1)}>Next</button>
          </div>
          <img src={photo.image} alt={photo.caption || 'Historical photograph'} />
          <h3 className="h5 mt-3">{photo.caption || 'Untitled photograph'}</h3>
          {photo.date && <p>{photo.date}</p>}
          {photo.creator && <p>{photo.creator}</p>}
          {photo.description && <p className="forge-photo-description">{photo.description}</p>}
          <p><a href={photo.url}>Open photograph record</a></p>
        </section>}
        <div className="forge-photo-grid">
          {gallery.photos.map((item, index) => <button key={item.id} type="button"
            className={`forge-photo-card ${selected === index ? 'selected' : ''}`}
            aria-pressed={selected === index} onClick={() => setSelected(index)}>
            <img src={item.thumbnail} alt={item.caption || 'Historical photograph'} loading="lazy" />
            <span>{item.caption || 'Untitled photograph'}</span>
            {item.date && <small>{item.date}</small>}
          </button>)}
        </div>
      </>}
  </ForgeModal>
}
