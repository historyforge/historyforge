# Develop HistoryForge in a container

This optional environment builds locally and includes Ruby 4.0.6 (matching
Gemfile), Node 22/Corepack, PostgreSQL 15, image libraries, and Chromium. It does
not require a registry account or affect the production Docker/Dokku workflow.

## Start

1. Install and start Docker with Docker Compose support.
2. Install VS Code and its Dev Containers extension.
3. Clone this repository, open the checkout in VS Code, and run
   **Dev Containers: Reopen in Container**.
4. Wait for the image build and `bin/setup` to finish. In the container terminal,
   run `bin/dev` and open the forwarded port at http://localhost:3000.

`bin/setup` installs locked Ruby and Yarn dependencies, builds JavaScript, copies
missing local configuration, generates development secrets, and prepares both
local databases. Existing `.env` and `config/database.yml` files are preserved.
For an existing database configuration, use the environment-aware settings in
`config/database.example.yml` so the database host is `db` inside the container.
Do not use production database credentials for development or tests.

The database contains the application's normal seeds, not a demonstration dataset.
Run `bin/rails init:new_admin_user` to create a local administrator, then configure
localities and enable the census years you need in the application settings.
See the [project documentation](https://historyforge.net/documentation) for those workflows.

## Verify changes

Run the full local check inside the container or after native setup:

```sh
bin/check
```

This builds JavaScript, checks Rails autoloading, and runs RSpec against the test
database. Chrome/Chromium runs headlessly by default. For a focused run, pass
RSpec arguments, for example `bin/check spec/models` or
`bin/check spec/features/media_spec.rb`. Use `HEADLESS=0 bin/check` to watch Chrome.

Once assets are built, `bundle exec rspec path/to/file_spec.rb:LINE` runs a single
example directly. Avoid simultaneous test processes against the same database:
some callback specs deliberately use real commits and clean up their own records.

The browser tests currently load some application dependencies from public CDNs,
so they need network access as well as PostgreSQL and Chrome. A successful unit
run alone does not establish that browser workflows pass.

## Native development

Install the Ruby version required by `Gemfile`, Node 22/Corepack, PostgreSQL 15 and
its client/development libraries, libvips, ImageMagick, and Chrome/Chromium.
Set `DATABASE_HOST`, `DATABASE_USERNAME`, and `DATABASE_PASSWORD` if your local
PostgreSQL does not use the example defaults (`localhost`, `postgres`, `postgres`).
Enable Yarn with `corepack enable` (install Corepack first if your Node distribution
does not include it). Then run `bin/setup` and `bin/dev`. Use `HEADLESS=1 bundle exec rspec` for headless tests.

## Maintenance and persistence

Source files are bind-mounted from your checkout; edits are immediately visible
on the host. PostgreSQL data lives in a named Docker volume and survives rebuilds.
The new PostgreSQL 15 volume does not reuse or delete an older container's data.
If you previously kept source changes only in the old workspace volume, copy or
commit those changes before switching to this setup; the old volume is not deleted.

After changing Ruby, update the Dockerfile to match `Gemfile`. Rebuild using
**Dev Containers: Rebuild Container**, then rerun `bin/setup` as needed.
Editor extensions and shell preferences beyond Ruby LSP are personal choices.

To check configuration or build without VS Code:

```sh
docker compose -f .devcontainer/docker-compose.yml config
docker compose -f .devcontainer/docker-compose.yml build
```
