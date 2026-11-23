import React from 'react'

// Render plain text as React nodes so descriptions cannot inject markup.
export default function LinkedText({ text }) {
  return (text || '').split(/(https?:\/\/[^\s<>"']+)/gi).map((part, index) => {
    if (!/^https?:\/\//i.test(part)) return part
    let url = part.replace(/[.,;:!?]+$/, '')
    // Leave prose punctuation outside the link, retaining balanced URL brackets.
    for (const [opening, closing] of [['(', ')'], ['[', ']']]) {
      while (url.endsWith(closing) && url.split(closing).length > url.split(opening).length) url = url.slice(0, -1)
    }
    return <React.Fragment key={index}><a href={url} target="_blank" rel="nofollow noopener noreferrer">{url}</a>{part.slice(url.length)}</React.Fragment>
  })
}
