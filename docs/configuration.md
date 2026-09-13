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

Choose [local or managed PostgreSQL](installation.md#choose-where-the-database-runs)
before setting the connection. The managed path includes CA mounting and verified TLS.

## Configure a new collection

Use Admin → Settings for sponsor name/URL, contact email, mail sender, map center,
census visibility, and building-entry permissions. Create localities separately.
Production census visibility defaults are disabled in the seeds; an empty or
hidden collection does not by itself indicate a deployment failure.

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
| `DISALLOW_INDEXING` | Set exactly `true` on a demo/QA site to send `X-Robots-Tag: noindex, nofollow`. Unset or other values leave indexing behavior unchanged. |
| `DATABASE_URL` | Database connection: supplied by the local Dokku Postgres link, or set explicitly for a managed cluster. |
| `SECRET_KEY_BASE` | Rails signing/encryption secret; generate locally and retain between releases. |
| `DEVISE_SECRET_KEY` | Devise authentication token secret; retain between releases. |
| `RAILS_ENV`, `RACK_ENV` | `production` for deployed sites. |
| `APP_NAME` | Site identity. |
| `BASE_URL` | Canonical hostname, such as `history.example.org`, used by mail and authentication defaults. |
| `WEBAUTHN_ORIGIN` | Exact HTTPS origin for passkeys, such as `https://history.example.org`. |
| `WEBAUTHN_RP_ID` | Passkey relying-party hostname, such as `history.example.org`. |
| `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` | Outgoing mail connection; use a capture service for QA. |
| `RAILS_MAX_THREADS` | Puma threads and the container database connection pool; tune together with memory and workload. |
| `FACEBOOK_LOGIN_APP_ID`, `FACEBOOK_LOGIN_SECRET` | Optional OAuth credentials read during initialization. |
| `AIRBRAKE_ID`, `AIRBRAKE_KEY`, `AIRBRAKE_URL` | Optional error reporting configuration. |

Choose a stable domain: changing it later can affect saved passkeys (the login
credentials stored on users' devices). SMTP being unset does not disable mail.
For a public site, test delivery to an address you control; for a trial, use the
mail capture arrangement described in [trying HistoryForge](trying-historyforge.md).

## Keep a public demo out of search results

Set the indexing flag on the demo app only, before its first deployment:

```sh
dokku config:set --no-restart historyforge-demo DISALLOW_INDEXING=true
```

For an already-running demo, omit `--no-restart` so the change takes effect after
restart. Do not set this globally or on public collection sites. The switch is
read at application startup and is not baked into the shared image.

The application adds `X-Robots-Tag: noindex, nofollow` to responses passing through
Rails, including Rails-served static files, redirects, and error responses. It
adds no login requirement. Files or errors served directly by a proxy, CDN, or
external storage service need their own header configuration if used.

There are two separate controls:

- **Crawling:** `robots.txt` keeps the existing exclusions for `/forge` and
  `/*/forge` on every site. All other paths are allowed to be crawled.
- **Indexing:** for pages crawlers can fetch, the response tells them whether to
  index the content. With `DISALLOW_INDEXING=true`, the demo sends the `noindex`
  header on every response through Rails. With the flag unset, real collection
  sites receive no additional indexing restriction from this feature.

The Forge is an interactive JavaScript map for exploring records. Its map view
offers little standalone content for a search result; the person, building, and
census record pages are more useful destinations. The crawl exclusions keep
crawlers out of that map interface while leaving the record pages available.
This is a choice about the usefulness of the map as a search result, not a claim
that search engines cannot process JavaScript.

Crawlers cannot see noindex on a URL they are forbidden to crawl;
this setting therefore cannot guarantee removal of already-indexed map URLs.
See [Google's indexing instructions](https://developers.google.com/search/docs/crawling-indexing/robots-meta-tag)
for that distinction. This is an indexing request to compliant search engines,
not access control.

After deployment, check the demo and a real collection site:

```sh
curl -sSI https://demo.example.org/check.txt
curl -sS https://demo.example.org/robots.txt
curl -sSI https://history.example.org/check.txt
```

Expect `X-Robots-Tag: noindex, nofollow` only on the demo, and the existing map
exclusions in its robots file. Use your actual hostnames when following these
examples. Unsetting the flag and restarting removes the added header; search
engines apply changes on their own crawl schedules.

## For contributors: settings in application code

Consult [mailer initialization](../config/initializers/historyforge_mailer.rb) and
[passkey configuration](../config/initializers/devise_passkeys.rb) when changing a
site's domain or mail provider. Changing the passkey relying-party domain affects
existing credentials; use a stable domain. SMTP being unset does not disable
production mail. Test invitations and resets with the chosen capture service
before loading demo accounts with real email addresses.

`SECRET_KEY_BASE_DUMMY` is used only by isolated build/smoke commands, not real
sites. `DEPLOYING` is a build-time asset flag, not a setting to leave enabled on
the application. The image contains its own database configuration: do not copy
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

