import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = {
    url: String
  }

  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      const query = this.inputTarget.value.trim()

      if (query.length > 0) {
        this.performSearch(query)
      } else {
        this.resultsTarget.innerHTML = ""
      }
    }, 300)
  }

  async performSearch(query) {
    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
      const html = await response.text()
      this.resultsTarget.innerHTML = html
    } catch (error) {
      console.error("Search failed:", error)
    }
  }

  clearResults() {
    this.resultsTarget.innerHTML = ""
  }
}
