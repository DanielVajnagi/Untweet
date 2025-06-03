# Untweet 🐦

Untweet is a simple Twitter clone built with Ruby on Rails

## 🔧 Tech Stack

- Ruby 3.3.4
- Rails 7.2.2
- PostgreSQL
- Devise (authentication)
- TailwindCSS
- Turbo + Stimulus (Hotwire)
- Importmap
- RSpec + FactoryBot + Shoulda Matchers
- Pretender (admin impersonation)
- Chewy + Elasticsearch (search)

## ⚙️ Setup

```bash
git clone https://github.com/DanielVajnagi/Untweet.git
cd untweet
bundle install
rails db:create db:migrate
bin/dev
