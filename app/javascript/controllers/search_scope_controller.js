import { Controller } from 'stimulus'

export default class extends Controller {
  submit({ target }) {
    target.form.requestSubmit()
  }
}
