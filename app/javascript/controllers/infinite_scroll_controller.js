import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    loading: { type: Boolean, default: false },
    lastCreatedAt: String,
    noMoreTweets: { type: Boolean, default: false },
    loadingMessage: String,
    noMoreTweetsMessage: String,
    errorMessage: String
  }
  static classes = ["loading"]

  connect() {
    console.log("Infinite scroll controller connected")
    console.log("Initial last created at:", this.lastCreatedAtValue)
    console.log("Container target:", this.containerTarget)

    // Ensure we have a valid lastCreatedAt value
    if (!this.lastCreatedAtValue) {
      const tweets = document.querySelectorAll('.tweet-item')
      if (tweets.length > 0) {
        const lastTweet = tweets[tweets.length - 1]
        this.lastCreatedAtValue = lastTweet.dataset.createdAt
        console.log("Set initial lastCreatedAt from DOM:", this.lastCreatedAtValue)
      }
    }

    this.setupIntersectionObserver()
  }

  disconnect() {
    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect()
    }
  }

  setupIntersectionObserver() {
    console.log("Setting up intersection observer")

    // Only disconnect if we're reconnecting
    if (this.intersectionObserver) {
      console.log("Disconnecting existing observer")
      this.intersectionObserver.disconnect()
    }

    this.intersectionObserver = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        const rect = entry.boundingClientRect
        console.log("Intersection observed:", {
          isIntersecting: entry.isIntersecting,
          loading: this.loadingValue,
          lastCreatedAt: this.lastCreatedAtValue,
          noMoreTweets: this.noMoreTweetsValue,
          target: entry.target,
          boundingClientRect: {
            top: rect.top,
            bottom: rect.bottom,
            height: rect.height,
            visible: rect.top < window.innerHeight && rect.bottom > 0
          }
        })

        if (entry.isIntersecting && !this.loadingValue && !this.noMoreTweetsValue) {
          console.log("Loading more tweets...")
          this.loadMore()
        }
      })
    }, {
      rootMargin: "200px",
      threshold: [0, 0.1, 0.5, 1.0]
    })

    // Make sure the container is still in the DOM
    if (this.containerTarget && document.body.contains(this.containerTarget)) {
      this.intersectionObserver.observe(this.containerTarget)
      console.log("Intersection observer set up and observing:", this.containerTarget)
    } else {
      console.error("Container target not found in DOM")
    }
  }

  async loadMore() {
    if (!this.lastCreatedAtValue) {
      console.log("No last created at value, stopping")
      return
    }

    if (this.loadingValue) {
      console.log("Already loading tweets, skipping")
      return
    }

    if (this.noMoreTweetsValue) {
      console.log("No more tweets to load")
      return
    }

    console.log("Starting to load more tweets...")
    this.loadingValue = true
    this.showLoadingIndicator()

    try {
      console.log("Fetching more tweets...")
      const url = `/tweets/load_more?last_created_at=${this.lastCreatedAtValue}`
      console.log("Request URL:", url)

      const response = await fetch(url, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html"
        }
      })
      console.log("Response status:", response.status)
      console.log("Response headers:", Object.fromEntries([...response.headers]))

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const html = await response.text()
      console.log("Response received:", html)

      if (html.trim()) {
        // Let Turbo handle the response
        Turbo.renderStreamMessage(html)

        // Wait for Turbo to finish rendering
        await new Promise(resolve => setTimeout(resolve, 500))

        // Update the last created at value
        this.updateLastCreatedAt()

        // Re-setup the intersection observer
        this.setupIntersectionObserver()
      } else {
        console.log("No more tweets to load (empty response)")
        this.noMoreTweetsValue = true
        this.showNoMoreTweetsMessage()
      }
    } catch (error) {
      console.error("Error loading more tweets:", error)
      this.containerTarget.innerHTML = `<div class="text-red-500">${this.errorMessageValue}: ${error.message}</div>`
    } finally {
      this.loadingValue = false
      this.hideLoadingIndicator()
    }
  }

  showLoadingIndicator() {
    console.log("Showing loading indicator")
    this.containerTarget.innerHTML = `
      <div class="loading-indicator text-center py-4 text-gray-500" style="min-height: 100px; display: flex; align-items: center; justify-content: center;">
        <div class="animate-spin inline-block w-6 h-6 border-2 border-gray-300 border-t-blue-600 rounded-full"></div>
        <span class="ml-2">${this.loadingMessageValue}</span>
      </div>
    `
  }

  hideLoadingIndicator() {
    console.log("Hiding loading indicator")
    if (!this.noMoreTweetsValue) {
      this.containerTarget.innerHTML = ''
    }
  }

  showNoMoreTweetsMessage() {
    console.log("Showing no more tweets message")
    this.containerTarget.innerHTML = `
      <div class="text-center py-4 text-gray-500" style="min-height: 100px; display: flex; align-items: center; justify-content: center;">
        <span>${this.noMoreTweetsMessageValue}</span>
      </div>
    `
  }

  updateLastCreatedAt() {
    // Get all tweet items
    const tweets = document.querySelectorAll('.tweet-item')
    console.log("Total tweets found:", tweets.length)

    if (tweets.length > 0) {
      // Get the last tweet element
      const lastTweet = tweets[tweets.length - 1]
      console.log("Last tweet element:", lastTweet)

      // Get the created_at data attribute
      const createdAt = lastTweet.dataset.createdAt
      console.log("Last tweet created_at:", createdAt)

      if (createdAt) {
        console.log("Current last created at:", this.lastCreatedAtValue)
        console.log("New last created at:", createdAt)

        // Only update if the new timestamp is different
        if (this.lastCreatedAtValue !== createdAt) {
          this.lastCreatedAtValue = createdAt
          console.log("Updated last created at to:", createdAt)

          // Verify the update
          console.log("Verified last created at:", this.lastCreatedAtValue)
        } else {
          console.log("Last created at unchanged - this might be why infinite scroll stopped")
          console.log("Current value:", this.lastCreatedAtValue)
          console.log("New value:", createdAt)

          // If the timestamp hasn't changed, try to find a different tweet
          const previousTweets = Array.from(tweets).slice(0, -1)
          if (previousTweets.length > 0) {
            const previousTweet = previousTweets[previousTweets.length - 1]
            const previousCreatedAt = previousTweet.dataset.createdAt
            if (previousCreatedAt && previousCreatedAt !== this.lastCreatedAtValue) {
              console.log("Using previous tweet's timestamp:", previousCreatedAt)
              this.lastCreatedAtValue = previousCreatedAt
            }
          }
        }
      } else {
        console.error("No created_at data attribute found on last tweet")
        console.log("Last tweet element:", lastTweet)
        console.log("Last tweet dataset:", lastTweet.dataset)
      }
    } else {
      console.error("No tweets found in the list")
    }
  }
}