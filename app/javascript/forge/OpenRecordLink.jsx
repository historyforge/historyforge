import React from 'react'

export default function OpenRecordLink({ href }) {
  return href ? <a className="forge-open-record" href={href} target="_blank" rel="noopener noreferrer" data-forge-exit="true">Open record <span aria-hidden="true">↗</span><span className="visually-hidden"> (new tab)</span></a> : null
}
