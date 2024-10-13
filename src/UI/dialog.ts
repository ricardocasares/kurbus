export default class extends HTMLElement {
  static observedAttributes = ['open']

  constructor() {
    super()
  }

  connectedCallback() {
    this.handle()
  }

  attributeChangedCallback() {
    this.handle()
  }

  handle() {
    const isOpen = this.getAttribute('open') !== null
    const dialog = this.querySelector('dialog')

    if (dialog) {
      if (isOpen) {
        dialog.onclick = event => {
          if (event.currentTarget === event.target) dialog.close()
        }
        dialog.showModal()
      } else {
        dialog.close()
      }
    }
  }
}
