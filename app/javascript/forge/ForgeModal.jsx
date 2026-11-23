import React, { useLayoutEffect, useRef } from 'react'
import { createPortal } from 'react-dom'
import { openDialog } from './openDialog'

export default function ForgeModal({ open, onClose, title, children, footer }) {
  const element = useRef(null)

  useLayoutEffect(() => {
    if (!open) return
    return openDialog(element.current)
  }, [open])

  if (!open) return null
  return createPortal(
    <dialog ref={element} className="forge-record-overlay" aria-labelledby="forge-modal-title"
      onCancel={event => { event.preventDefault(); onClose() }}>
      <header>
        <h2 id="forge-modal-title">{title}</h2>
        <button type="button" className="btn btn-light" onClick={onClose} autoFocus>Close</button>
      </header>
      <div className="forge-overlay-content">{children}</div>
      {footer && <footer>{footer}</footer>}
    </dialog>, document.body
  )
}
