document.addEventListener('click', event => {
  const link = event.target.closest('[data-href]')
  if (link) window.open(link.dataset.href, '_blank', 'noopener')
})
