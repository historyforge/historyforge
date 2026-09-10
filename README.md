# HistoryForge

[![Maintainability](https://api.codeclimate.com/v1/badges/ba4431ae9e5100c088e4/maintainability)](https://codeclimate.com/github/historyforge/historyforge/maintainability)

This is HistoryForge. It is a basic Rails application.

## Setup Production Environment

See the wiki page.

## Development

See the [development guide](.devcontainer/README.md) for the optional Docker/VS Code
container, native setup, and test commands. Both paths use `bin/setup`, followed
by `bin/dev` to start the application.

Bullet is disabled by default. Start with `BULLET=1 bin/dev` to investigate query
performance, or `BULLET=1 bin/check` to log warnings during tests. Set this in the
shell before starting the process; a `.env` setting is too late for gem loading.

Application-specific mail settings live in `config/initializers/historyforge_mailer.rb`.
Settings needed during early boot are grouped under “HistoryForge configuration”
at the bottom of `config/application.rb` and the environment files. Preserve those
sections when running `rails app:update`. 
