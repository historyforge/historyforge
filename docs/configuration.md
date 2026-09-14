# Site configuration

Use this with [first installation](installation.md) and [ongoing operation](operating.md).

There are two places to configure a site:

- **In the browser, under Admin → Settings:** change your organization's details,
  contact and sender addresses, map center, and which census years visitors can see.
- **On the server, through Dokku:** configure the database connection, outgoing
  email service, domain, and application secrets. These are called environment
  variables because Dokku supplies them to the application when it starts.

Most day-to-day collection changes belong in the browser. Do not edit source
code or build an image to change your community's settings. Initial defaults
include Tompkins/Ithaca details; review and replace them for your community,
including county, city, state, sponsor, contact address, and map center.

The sender address identifies outgoing mail; the SMTP settings connect to the
service that delivers it. Configure both. The contact address is where messages
from your site's contact form should arrive.

The basic installation guide configures the local database connection for you.
For a separate database service, follow [managed PostgreSQL](managed-postgresql.md).

## Configure a new collection

Use Admin → Settings for sponsor name/URL, contact email, mail sender, map center,
census visibility, and building-entry permissions. Create localities separately.
Census years start hidden on a new hosted site. Enable the years you want
people to work on, and choose when to make them visible to public visitors.
An empty search page may mean the year is hidden or has no published records.

The default street map uses OpenFreeMap; displaying it does not require a Google
Maps account. Converting addresses into map coordinates is a separate operation,
called geocoding, which uses a configured Google geocoding key. Set up the
integrations you intend to use and verify them with your own records.

Contact-form reCAPTCHA is enabled when both `recaptcha_site_key` and
`recaptcha_secret_key` are present. Configure credentials appropriate to the site
and test the form. Facebook authentication is optional; configure its enabled
setting and startup credentials together if used. External service account setup
and pricing belong in those providers' current documentation.

## Server settings

Set these with `dokku config:set --no-restart APP KEY=value` before deploying, or
restart the app after changing them on an existing installation. Replace `APP`
with your Dokku app name. For example, on the server:

```sh
dokku config:set community-hf APP_NAME='Our Community HistoryForge'
```

For an existing site, omitting `--no-restart` makes the change take effect by
restarting the application. The installation guide uses `--no-restart` because
the app has not been deployed yet. Keep passwords and application secrets private.

| Variable | Purpose |
| --- | --- |
| `DISALLOW_INDEXING` | Set exactly `true` to ask search engines to exclude this installation using `X-Robots-Tag: noindex, nofollow`. Unset or other values leave indexing behavior unchanged. |
| `DATABASE_URL` | Database connection: supplied by the local Dokku Postgres link, or set explicitly for a managed cluster. |
| `SECRET_KEY_BASE` | Rails signing/encryption secret; generate locally and retain between releases. |
| `DEVISE_SECRET_KEY` | Devise authentication token secret; retain between releases. |
| `RAILS_ENV`, `RACK_ENV` | `production` for deployed sites. |
| `APP_NAME` | Site identity. |
| `BASE_URL` | Canonical hostname, such as `history.example.org`, used by mail and authentication defaults. |
| `WEBAUTHN_ORIGIN` | Exact HTTPS origin for passkeys, such as `https://history.example.org`. |
| `WEBAUTHN_RP_ID` | Passkey relying-party hostname, such as `history.example.org`. |
| `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` | Outgoing mail service connection. |
| `RAILS_MAX_THREADS` | Puma threads and the container database connection pool; tune together with memory and workload. |
| `FACEBOOK_LOGIN_APP_ID`, `FACEBOOK_LOGIN_SECRET` | Optional OAuth credentials read during initialization. |
| `AIRBRAKE_ID`, `AIRBRAKE_KEY`, `AIRBRAKE_URL` | Optional error reporting configuration. |

Choose a stable domain: changing it later can affect saved passkeys (the login
credentials stored on users' devices). SMTP being unset does not disable mail.
Test delivery to an address you control before inviting community members.

## Search engine visibility

For a public community collection, leave `DISALLOW_INDEXING` unset. Search
engines can discover its person, building, and census record pages.
A development site running only on your computer at `localhost` is not publicly
reachable and does not need this setting.

The Forge itself is an interactive JavaScript map. Its map view offers little
standalone content for a search result; the individual record pages are more
useful destinations. For that reason, `robots.txt` excludes `/forge` and
`/*/forge` from crawling on every site, while allowing other pages.

If you have a publicly reachable installation that you want excluded from search
results, set this on that app, replacing `community-hf` with its Dokku app name:

```sh
dokku config:set community-hf DISALLOW_INDEXING=true
```

This restarts the app and adds an HTTP `X-Robots-Tag: noindex, nofollow` header.
During initial installation, add `--no-restart` and the setting will take effect
on the first deployment. It applies to this installation, not every site using
the shared image. To return to normal indexing behavior:

```sh
dokku config:unset community-hf DISALLOW_INDEXING
```

This is a request to search engines, not privacy or access control. People can
still visit the site. Search engines must be able to crawl a page to read the
header, so it cannot guarantee removal of map URLs already excluded by
`robots.txt`. See [Google's indexing instructions](https://developers.google.com/search/docs/crawling-indexing/robots-meta-tag).
The header covers responses served through the application; content served
separately by a proxy or external storage needs its own configuration.

## For contributors: settings in application code

Consult [mailer initialization](../config/initializers/historyforge_mailer.rb) and
[passkey configuration](../config/initializers/devise_passkeys.rb) when changing a
site's domain or mail provider. Changing the passkey relying-party domain affects
existing credentials; use a stable domain. SMTP being unset does not disable
production mail. For release testing, use the email precautions in
[testing a release on a separate site](deployment.md#test-a-release-on-a-separate-site).

`SECRET_KEY_BASE_DUMMY` is used only by isolated build/smoke commands, not real
sites. The image contains its own database configuration: do not copy
a developer's `config/database.yml` into a deployment.

The current API is `AppConfig[:mail_from]`, not `AppConfig.mail_from`.
[AppConfig](../app/models/app_config.rb) loads database settings and falls back to
an uppercase environment key. The implementation uses Ruby `||`: a database
`false` also falls through to the environment. Treat this as existing behavior,
not a reliable way to override a boolean with an environment string.

[Setting.add](../app/models/setting.rb) creates missing settings; it does not
replace an existing setting's value or metadata. Changing a seed default or its
source environment variable will not overwrite an administrator's existing value.
Edit the setting in the UI or write an explicit migration when that is intended.
Avoid AppConfig in initialization that must work before a database is available;
it calls `Setting.load` first. The mailer correctly reads its boot configuration
directly from ENV.

Add a new setting in [db/seeds.rb](../db/seeds.rb), for example:

```ruby
Setting.add 'be_happy', type: :boolean, value: '1', group: 'Faces',
            name: 'Show a happy face', hint: 'Display a happy face on census pages.'
```

Read it as `AppConfig[:be_happy]`. Supported types are `boolean` (`'1'` is true),
`integer`, `number`, and string. Update example configuration when introducing a
startup environment variable; include the app name in every Dokku config command.
