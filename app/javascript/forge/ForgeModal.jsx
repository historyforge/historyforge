import React, { useLayoutEffect, useRef } from 'react'
import { createPortal } from 'react-dom'

export default function ForgeModal({ open, onClose, title, size, children, footer }) {
  const element = useRef(null)
  const close = useRef(onClose)
  close.current = onClose

  useLayoutEffect(() => {
    if (!open) return

    const dialog = element.current
    const previousFocus = document.activeElement
    const modal = new window.bootstrap.Modal(dialog)
    const onHidden = () => close.current()
    dialog.addEventListener('hidden.bs.modal', onHidden)
    modal.show()

    return () => {
      dialog.removeEventListener('hidden.bs.modal', onHidden)
      modal.hide()
      modal.dispose()
      previousFocus?.focus()
    }
  }, [open])

  if (!open) return null

  return createPortal(
    <div className="modal" ref={element} tabIndex={-1} aria-labelledby="forge-modal-title">
      <div className={size ? `modal-dialog modal-${size}` : 'modal-dialog'}>
        <div className="modal-content">
          <div className="modal-header">
            <h5 id="forge-modal-title" className="modal-title">{title}</h5>
            <button type="button" className="btn-close" aria-label="Close" data-bs-dismiss="modal" />
          </div>
          <div className="modal-body">{children}</div>
          {footer && <div className="modal-footer">{footer}</div>}
        </div>
      </div>
    </div>,
    document.body
  )
}
