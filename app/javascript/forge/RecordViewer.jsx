import PlaceView from './PlaceView'
import React, { createContext, useContext, useEffect, useLayoutEffect, useRef, useState } from 'react'
import { createPortal } from 'react-dom'
import { openDialog } from './openDialog'

const RecordContext = createContext(null)

export function RecordLink({ href, children, ...props }) {
  const open = useContext(RecordContext)
  return <a {...props} href={href} onClick={event => { event.preventDefault(); open(href) }}>{children}</a>
}

// Keep the existing record pages and their authorization checks inside the Forge.
export function RecordProvider({ children }) {
  const [placeTitle, setPlaceTitle] = useState('Loading place…')
  const [history, setHistory] = useState([])
  const [openSequence, setOpenSequence] = useState(0)
  const [loading, setLoading] = useState(true)
  const dialog = useRef(null)
  const frame = useRef(null)
  const active = history.length > 0
  const url = history[history.length - 1]
  const placeId = url?.match(/^\/buildings\/(\d+)(?:\?|$)/)?.[1]
  const open = path => {
    const next = new URL(path, window.location.origin)
    if (next.origin !== window.location.origin) return
    next.searchParams.set('forge_view', '1')
    setLoading(true)
    setOpenSequence(current => current + 1)
    setHistory(current => [...current, next.pathname + next.search + next.hash])
  }

  useLayoutEffect(() => {
    if (!active) return
    return openDialog(dialog.current)
  }, [active, openSequence])

  useEffect(() => {
    const navigate = event => {
      if (event.origin !== window.location.origin || event.source !== frame.current?.contentWindow) return
      if (event.data?.type === 'forge:ready') setLoading(false)
      if (event.data?.type === 'forge:navigate') open(event.data.url)
      if (event.data?.type === 'forge:close') setHistory([])
    }
    window.addEventListener('message', navigate)
    return () => window.removeEventListener('message', navigate)
  }, [])

  useEffect(() => {
    const navigate = event => {
      const link = event.target.closest('a[href]')
      if (!link || link.getAttribute('href').startsWith('#')) return
      const destination = new URL(link.href)
      if (destination.origin !== window.location.origin || /\/forge\/?$/.test(destination.pathname)) return
      event.preventDefault()
      event.stopImmediatePropagation()
      open(destination.href)
    }
    document.addEventListener('click', navigate, true)
    return () => document.removeEventListener('click', navigate, true)
  }, [])

  return <RecordContext.Provider value={open}>
    {children}
    {active && createPortal(<dialog ref={dialog} className="forge-record-overlay" aria-label="Record details"
      onCancel={event => { event.preventDefault(); setHistory([]) }}>
      <header>
        <button type="button" className="btn btn-light" disabled={history.length < 2}
          onClick={() => { setLoading(true); setHistory(current => current.slice(0, -1)) }}>Back</button>
        <h2>{placeId ? placeTitle : loading ? 'Loading…' : 'Explore HistoryForge'}</h2>
        <button type="button" className="btn btn-light" onClick={() => setHistory([])} autoFocus>Close</button>
      </header>
      {placeId ? <div className="forge-overlay-content" key={placeId}><PlaceView onTitle={setPlaceTitle} id={placeId} onNavigate={open} /></div> : <iframe key={url} ref={frame} src={url} title="HistoryForge record" onLoad={() => setLoading(false)}
        sandbox="allow-same-origin allow-scripts allow-forms" />}
    </dialog>, document.body)}
  </RecordContext.Provider>
}
