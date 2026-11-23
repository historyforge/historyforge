import { RecordLink } from './RecordViewer'
import React, { useEffect, useLayoutEffect, useRef, useState } from 'react'
import { createPortal } from 'react-dom'
import { useDispatch, useSelector } from 'react-redux'
import axios from 'axios'
import { openDialog } from './openDialog'

export default function PhotoGallery() {
  const id = useSelector(state => state.buildings.photoBuildingId)
  const openSequence = useSelector(state => state.buildings.photoOpenSequence)
  const dispatch = useDispatch()
  const dialog = useRef(null)
  const [gallery, setGallery] = useState(null)
  const [selected, setSelected] = useState(0)
  const [error, setError] = useState(false)
  const [attempt, setAttempt] = useState(0)
  const close = () => dispatch({ type: 'PHOTO_BUILDING_DESELECT' })

  useLayoutEffect(() => {
    if (!id) return
    return openDialog(dialog.current)
  }, [id, openSequence])

  useEffect(() => {
    let active = true
    setGallery(null)
    setSelected(0)
    setError(false)
    if (id) axios.get(`/forge/buildings/${id}/photographs`).then(({ data }) => {
      if (active) setGallery(data)
    }).catch(() => { if (active) setError(true) })
    return () => { active = false }
  }, [id, attempt])

  useEffect(() => {
    dialog.current?.querySelector('.forge-photo-card.selected')?.scrollIntoView({ block: 'nearest', inline: 'center', behavior: window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth' })
  }, [selected, gallery])

  if (!id) return null
  const photo = gallery?.photos[selected]
  return createPortal(<dialog ref={dialog} className="forge-photo-overlay" aria-labelledby="forge-photo-title"
    onCancel={event => { event.preventDefault(); close() }}>
    <header className="forge-photo-header">
      <div>
        <h2 id="forge-photo-title">{gallery?.address || 'Photographs'}</h2>
        {gallery && <RecordLink href={gallery.url}>Explore this place</RecordLink>}
      </div>
      <button type="button" className="forge-photo-close" aria-label="Close photographs" onClick={close} autoFocus>
        <span aria-hidden="true">×</span>
      </button>
    </header>
    {error ? <div className="forge-photo-message" role="alert">Unable to load photographs. <button type="button" className="btn btn-light" onClick={() => setAttempt(attempt + 1)}>Try again</button></div>
      : !gallery ? <p className="forge-photo-message" role="status">Loading photographs…</p>
        : !photo ? <p className="forge-photo-message">No photographs are available for this building.</p> : <>
          <nav className="forge-photo-strip" aria-label="Photographs at this building">
            {gallery.photos.map((item, index) => <button key={item.id} type="button"
              className={`forge-photo-card${selected === index ? ' selected' : ''}`}
              aria-label={`Photograph ${index + 1}: ${item.caption || 'Untitled photograph'}${item.date ? ` (${item.date})` : ''}`}
              aria-pressed={selected === index} onClick={() => setSelected(index)}>
              <img src={item.thumbnail} alt="" loading="lazy" />
              <span>{item.date || `Photograph ${index + 1}`}</span>
            </button>)}
          </nav>
          <section className="forge-photo-viewer" aria-label="Selected photograph">
            <div className="forge-photo-image"><img key={photo.id} src={photo.image} alt={photo.caption || 'Historical photograph'} /></div>
            <div className="forge-photo-details">
              {gallery.photos.length > 1 && <nav className="forge-photo-navigation" aria-label="Photo navigation">
                <button type="button" className="btn btn-outline-secondary" disabled={selected === 0} onClick={() => setSelected(selected - 1)}>Previous</button>
                <span aria-live="polite">{selected + 1} of {gallery.photos.length}</span>
                <button type="button" className="btn btn-outline-secondary" disabled={selected === gallery.photos.length - 1} onClick={() => setSelected(selected + 1)}>Next</button>
              </nav>}
              <div key={photo.id} className="forge-photo-copy">
              {photo.date && <p className="forge-photo-date">{photo.date}</p>}
              <h3>{photo.caption || 'Untitled photograph'}</h3>
              {photo.creator && <p className="forge-photo-creator">{photo.creator}</p>}
              {photo.description && <p className="forge-photo-description">{photo.description}</p>}

              </div>
            </div>
          </section>
        </>}
  </dialog>, document.body)
}
