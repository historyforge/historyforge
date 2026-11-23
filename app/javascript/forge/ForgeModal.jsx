import OpenRecordLink from './OpenRecordLink'
import React, { useLayoutEffect, useRef } from 'react'
import { createPortal } from 'react-dom'
import { openDialog } from './openDialog'

export default function ForgeModal({ open, onClose, title, recordUrl, children, footer }) {
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
        <div><h2 id="forge-modal-title">{title}</h2><OpenRecordLink href={recordUrl} /></div>
        <button type="button" className="forge-photo-close" aria-label="Close" onClick={onClose} autoFocus><span aria-hidden="true">×</span></button>
      </header>
      <div className="forge-overlay-content">{children}</div>
      {footer && <footer>{footer}</footer>}
    </dialog>, document.body
  )
}
