# HistoryForge

[![Maintainability](https://api.codeclimate.com/v1/badges/ba4431ae9e5100c088e4/maintainability)](https://codeclimate.com/github/historyforge/historyforge/maintainability)

This is HistoryForge. It is a basic Rails application.

## Setup for Local Development
1. Clone the repo
2. `bundle install`
3. `cp config/database.yml.example config/database.yml`
4. `cp .exampleenv .env`, open and fill in the values.
5. `rails db:create db:seed init`
6. `rails server`

Looking for sample census data? There isn't yet, but it is on the horizon.

## Running the Test Suite
### Setup for testing
```
rails db:test:prepare
rails db:seed RAILS_ENV=test
```

### Run the tests
```
rspec
```

## Setup Production Environment

See the wiki page.
