let openCount = 0
let originalOverflow

// Overlays can close in a different order from the one in which they opened.
export function openDialog(element) {
  const previousFocus = document.activeElement
  element.showModal()
  if (openCount++ === 0) originalOverflow = document.body.style.overflow
  document.body.style.overflow = 'hidden'
  return () => {
    element.close()
    if (--openCount === 0) document.body.style.overflow = originalOverflow
    if (previousFocus?.isConnected) previousFocus.focus()
  }
}
