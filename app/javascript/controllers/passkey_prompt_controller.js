import { Controller } from 'stimulus'
import { generateDeviceLabel, registerPasskey } from '../passkeys'

const dismissedCookie = 'passkey_prompt_dismissed'

export default class extends Controller {
  connect() {
    if (!window.PublicKeyCredential || document.cookie.split('; ').some(cookie => cookie.startsWith(dismissedCookie + '='))) return

    this.rememberDismissal = () => {
      document.cookie = dismissedCookie + '=1; Max-Age=2592000; Path=/; SameSite=Lax'
    }
    this.element.addEventListener('hidden.bs.modal', this.rememberDismissal)
    this.modal = new window.bootstrap.Modal(this.element)
    this.modal.show()
  }

  disconnect() {
    if (!this.modal) return

    this.element.removeEventListener('hidden.bs.modal', this.rememberDismissal)
    this.modal.hide()
    this.modal.dispose()
    this.modal = null
  }

  async setup({ currentTarget: button }) {
    const { challengeUrl, createUrl } = button.dataset
    const label = button.innerHTML
    button.disabled = true
    button.textContent = 'Setting up...'

    try {
      await registerPasskey(challengeUrl, createUrl, generateDeviceLabel())
    } catch (error) {
      alert('Failed to set up passkey: ' + error.message)
      button.disabled = false
      button.innerHTML = label
    }
  }
}
