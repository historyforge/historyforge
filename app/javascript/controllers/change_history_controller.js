import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.buttons = []
    this.frame = requestAnimationFrame(() => {
      for (const row of this.element.querySelectorAll('.change-history-row')) {
        const pair = [...row.querySelectorAll('.truncate-text[data-row-id]')]
        if (pair.length) this.addToggle(pair, row)
        for (const text of row.querySelectorAll('.truncate-text:not([data-row-id])')) {
          this.addToggle([text], text)
        }
      }
    })
  }

  disconnect() {
    cancelAnimationFrame(this.frame)
    this.buttons.forEach(button => button.remove())
    this.element.querySelectorAll('.truncate-text.expanded').forEach(text => text.classList.remove('expanded'))
  }

  addToggle(texts, target) {
    const needsToggle = texts.some(text => {
      const value = text.textContent.trim()
      return value && value !== 'blank' && (value.length > 50 || text.scrollHeight > text.clientHeight + 10)
    })
    if (!needsToggle) return

    const button = document.createElement('button')
    button.type = 'button'
    button.className = 'read-more-link visible btn btn-sm btn-link p-0'
    button.textContent = 'Read more'
    button.setAttribute('aria-expanded', 'false')
    button.addEventListener('click', () => {
      const expanded = !texts[0].classList.contains('expanded')
      texts.forEach(text => text.classList.toggle('expanded', expanded))
      button.textContent = expanded ? 'Read less' : 'Read more'
      button.setAttribute('aria-expanded', String(expanded))
    })
    target.after(button)
    this.buttons.push(button)
  }
}
