import {Controller} from "stimulus";

export default class extends Controller {
    connect() {
        $(this.element).blowup({scale: 2, cursor: false, width: 300, height: 300})
    }
}
