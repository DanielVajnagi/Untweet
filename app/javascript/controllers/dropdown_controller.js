import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  initialize() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    this.boundHandleKeyDown = this.handleKeyDown.bind(this)
  }

  connect() {
    this.addEventListeners()
  }

  disconnect() {
    this.removeEventListeners()
    this.hideMenu()
  }

  addEventListeners() {
    document.addEventListener('click', this.boundHandleClickOutside)
    document.addEventListener('keydown', this.boundHandleKeyDown)
  }

  removeEventListeners() {
    document.removeEventListener('click', this.boundHandleClickOutside)
    document.removeEventListener('keydown', this.boundHandleKeyDown)
  }

  toggle(event) {
    event.stopPropagation()
    const menu = this.menuTarget

    // Hide any other open menus first
    document.querySelectorAll('.share-menu.show').forEach(openMenu => {
      if (openMenu !== menu) {
        openMenu.classList.remove('show')
      }
    })

    menu.classList.toggle('show')
  }

  hideMenu() {
    this.menuTarget.classList.remove('show')
  }

  handleClickOutside = (event) => {
    const menu = this.menuTarget
    const isClickInsideMenu = menu.contains(event.target)
    const isClickOnTrigger = event.target.closest('[data-action="click->dropdown#toggle"]')

    if (!isClickInsideMenu && !isClickOnTrigger && menu.classList.contains('show')) {
      this.hideMenu()
    }
  }

  handleKeyDown = (event) => {
    if (event.key === 'Escape' && this.menuTarget.classList.contains('show')) {
      this.hideMenu()
    }
  }
}
