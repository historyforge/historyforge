# Install a new HistoryForge site

This guide explains how to launch a HistoryForge site for your community. It covers a 
**new, empty installation** on Dokku. For an existing site,
use [updating and maintaining your site](operating.md). For local development, use
[the development guide](../.devcontainer/README.md). For an overview of local exploration and starting a collection, see
[exploring HistoryForge](trying-historyforge.md).

## What is Dokku?

[Dokku](https://dokku.com/) is free, open-source software that helps you run web
applications on a server you control. You install it on a server rented from a
hosting provider, such as DigitalOcean. Dokku then handles much of the work of
starting your application, directing visitors to it, and replacing it when you
deploy an update. You operate it through commands over SSH, a secure connection
from your computer to the server.

HistoryForge is the application your visitors use; Dokku is the software that
manages it on the server. Dokku uses Docker to run the application in a
**container**. A container starts from an **image**: a packaged copy of
HistoryForge containing its code, Ruby, and the libraries it needs. This lets us
build a release once and run that same release on several installations.

In this guide, you will add a Dokku plugin for HTTPS certificates and choose
where PostgreSQL runs: on your Dokku server or in a separate managed database
service. The local option uses another Dokku plugin to manage PostgreSQL. The database holds your site's records and user accounts.
A separate storage directory holds uploaded files, so they survive application
updates. One Dokku server can host several HistoryForge sites, each with its own
domain, database, configuration, and uploaded files.

Dokku makes deployment easier, but you still manage the server, its updates,
backups, and available disk space and memory. Your hosting provider supplies the
server; Dokku runs on it. The steps below explain how to put these pieces together
for your first site.

## Guide status

The container build and startup with a fresh PostgreSQL 17 schema have been tested
locally. The complete installation on a Dokku server, including the managed
database option, has not yet been verified end to end. The commands below are a
first-install procedure under validation.

## How to follow this guide

You do not need to clone this repository or install Ruby, Docker, or development
software on your own computer. You need a terminal application to connect to
your hosting server. Docker and Dokku run on that server.

The work happens in three places:

- **Your hosting and domain accounts:** rent the server and configure its address.
- **A terminal connected to the server:** run the command blocks in this guide.
- **HistoryForge in your browser:** initialize your collection's settings and enter records.

A command block is text to paste into the terminal. Replace example values such
as `community-hf`, `history.example.org`, and `YOUR_OPERATOR_EMAIL` with your own.
Names beginning with `HF_` are temporary variables: they save a value for later
commands. Keep the same terminal connection open; if you reconnect, set the
variables again before continuing. Do not rerun commands that create the app or
load its empty database simply to restore those variables.

Work through the numbered steps in order, choosing either database option A or
B wherever offered. If a command reports an error, stop at that step and resolve
it before proceeding. Keep the error text for troubleshooting, excluding
passwords and connection URLs that contain them.

You can learn this as you go. If server setup is unfamiliar, a technical volunteer
can help with hosting, backups, and updates while your community manages the
collection through the browser. Keep hosting, domain, and recovery information
accessible to the people responsible for the site, rather than only on one
volunteer's computer.

## 1. Arrange hosting and your site address

Before starting, arrange these four things. You do not need to know every command
yet; the later steps explain how to connect them.

1. **A server to run the site.** This is a computer that stays online and receives
   requests from visitors. You can rent one from a hosting provider such as
   DigitalOcean, where it is called a “droplet.” You can also use an existing
   Dokku server with room for another application. Each HistoryForge site gets
   its own app, database, and uploaded-file storage, even when sharing a server.
2. **An address for visitors.** Choose a domain or subdomain you control, such as
   `history.example.org`. In that domain's DNS settings, create an A record
   pointing the chosen name to the server's IP address. This gets visitors to the
   server; later you will tell Dokku which app should answer for that name and
   obtain an HTTPS certificate. Until then, the address may show another site on
   the server or a certificate warning. The domain does not have to end in
   `historyforge.net`.
3. **Administrative access to the server.** SSH lets you open a terminal session
   on the server from your own computer. You need an account with permission to
   install and configure Dokku, usually through a root account or `sudo`. Your
   hosting provider's instructions explain how to register an SSH key and connect.
   Access to HistoryForge's administrator web interface is a separate account
   that you will create after installation.
4. **HistoryForge itself.** The maintainer supplies a ready-to-run package named
   `dfurber/historyforge:latest`. The commands in this guide download it for you.
   You can use that name as written; you do not need to create your own package
   or a Docker Hub account for this installation path.

### Use the ready-made HistoryForge package

For most installations, use:

```text
dfurber/historyforge:latest
```

This is the name Docker uses to find HistoryForge on Docker Hub. Docker Hub is a
place where software packages are stored for download; Docker calls that kind of
service a **registry**. The package itself is called an **image**. You do not need
to operate a registry or learn how to build images to follow this guide.

The `latest` part selects the package the maintainer currently publishes under
that name. It can change when a new version is published, but your running site
will not update itself just because that happens. Updating is a separate action.
Later commands download the package and record its exact identifier so database
setup and deployment use the same downloaded version.

You can still give your site its own name, domain, localities, census years,
records, and administrator settings. Those choices do not require a custom image.
Ruby and the application's runtime libraries are included in the package.

## Choose where the database runs

PostgreSQL stores the records, users, and settings for your site. HistoryForge can
connect to it in either of these arrangements:

- **Local PostgreSQL:** Dokku runs PostgreSQL in a separate container on the same
  server as HistoryForge. Here “local” means your hosting server, not your laptop.
  You maintain the database along with the server.
- **Managed PostgreSQL cluster:** a provider runs PostgreSQL separately, and
  HistoryForge connects to it over the network. You create a database and user
  within that service. The provider manages the database infrastructure; you
  still manage your data, access permissions, and application migrations.

A cluster is the database service, not a HistoryForge installation. It can hold
several databases. Depending on the plan it may have only one database server;
replicas and automatic failover are features to check, not guarantees of the word
“cluster.” Give each site its own database and credentials, even when sharing a
cluster. Shared resources still mean one site's workload can affect another.

| Consideration | On the Dokku server | Managed cluster |
| --- | --- | --- |
| Cost and setup | Uses the server you already rent; fewer services to configure. | Adds a separately billed service and network/credential setup. |
| Resources | Database and application share RAM, CPU, and disk. | Database capacity is separate from application capacity. |
| Maintenance | You arrange database updates, backups, and recovery. | Provider handles infrastructure maintenance; check backup retention, restore options, and upgrade policies. |
| Failure | A server failure affects both app and database. | Database can survive an app-server failure; database availability depends on its own plan and network. |
| Connection | Dokku's database link supplies the connection URL. | You supply the service's connection URL, network access, and TLS trust configuration. |

Local PostgreSQL is a straightforward starting point for a small standalone site.
A managed cluster is useful when you want separate database capacity and less
infrastructure maintenance. Neither option removes the need to test restores.
Choose one path below. These are new-install instructions, not a procedure for
moving an existing database between the two.

## 2. Prepare the host

Install Dokku using its [current installation instructions](https://dokku.com/docs/getting-started/installation/),
including SSH key registration and the global domain. Choose an operating system
supported by the Dokku version you install; its installation page lists the
current requirements.
A firewall controls which network connections can reach the server. Allow SSH
(usually port 22), HTTP (port 80), and HTTPS (port 443) through both the server
and hosting provider firewalls. Set the
site's DNS A record to the host; only publish an AAAA record if IPv6 also works.

During an update, Dokku may run the current application and its replacement
at the same time. The server needs memory for both, plus PostgreSQL if it runs
locally. Dokku's minimum requirements alone do not establish enough capacity for
HistoryForge. We have not yet measured a recommended server size.

Open a terminal on your computer and connect using `ssh root@YOUR_HOST`,
replacing `YOUR_HOST` with your server's IP address or hostname. The commands
below run in that server session. They assume a root account, which has full
administrative access; use your provider's instructions if your account uses
`sudo` instead.
For an existing Dokku host, reuse installed plugins rather than reinstalling them.

```sh
dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
```

## 3. Create the app, storage, and database

Set these variables in the server shell. Keep the same shell for subsequent
steps, or set them again when reconnecting.
Choose app and database names that identify your community. The examples use
`community-hf`; replace that name and `history.example.org` with your own values.
Leave `HF_IMAGE` as written unless you have built a custom version.

```sh
HF_APP=community-hf
HF_DB=community-hf
HF_DOMAIN=history.example.org
HF_IMAGE='dfurber/historyforge:latest'
HF_STORAGE="/var/lib/dokku/data/storage/$HF_APP"

dokku apps:create "$HF_APP"
dokku domains:set "$HF_APP" "$HF_DOMAIN"
install -d -o 32767 -g 32767 -m 0750 "$HF_STORAGE"
dokku storage:mount "$HF_APP" "$HF_STORAGE:/app/storage"
```

Use a unique storage directory per site. UID/GID 32767 matches the image's runtime
user. These numbers give the application permission to write uploaded files.
The storage connection (called a mount) keeps those files outside the replaceable
application container, so application updates preserve them.

### Option A: PostgreSQL on the Dokku server

Install the Postgres plugin if this host does not already have it, then create and
link the new database. This sets `DATABASE_URL` on the application automatically.
Do not also follow option B.

```sh
dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
dokku postgres:create "$HF_DB" --image-version 17-bookworm
dokku postgres:link "$HF_DB" "$HF_APP"
```

PostgreSQL 17 is the version tested with the application image. Record the selected version
and follow the [Postgres plugin documentation](https://github.com/dokku/dokku-postgres)
for upgrades and backups. The schema uses `fuzzystrmatch` and `pg_trgm`, not PostGIS.
Keep the database port private. Continue with step 4, then bootstrap using option A
in step 5.

### Option B: an external managed PostgreSQL cluster

You do not need the Dokku Postgres plugin for this option. Do not create or link a
local service: the provider supplies PostgreSQL and you set `DATABASE_URL` yourself.
The following is a concrete example for DigitalOcean Managed PostgreSQL Standard
Edition; other providers have equivalent database, user, network, and TLS settings.

1. Create or select a PostgreSQL cluster. Choose a compatible major version;
   PostgreSQL 17 is the version tested with the application image. For private connectivity, place the
   application host and cluster in the same reachable private network.
2. Create a **new database** such as `community_hf` and a dedicated user.
   Give that user ownership or the privileges needed to create tables, indexes,
   functions, and extensions in that database. Do not use a shared production
   database or the provider's general-purpose default database.
3. Allow connections from the application server in the cluster's trusted sources.
   Use the private hostname when network routing permits it; otherwise restrict
   the public endpoint to the server's outgoing IP. Containers must be able to
   reach the endpoint too.
4. Obtain the direct database connection URI for this database and user. Keep the
   supplied hostname and port. Use the direct endpoint initially, not a transaction
   pooling endpoint, so schema loading and migrations use a normal connection.
5. Download the cluster's CA certificate to the Dokku server. Configure verified
   TLS as shown below, using the provider's hostname rather than an IP address.

DigitalOcean's [connection instructions](https://docs.digitalocean.com/products/databases/postgresql/how-to/connect/)
and [trusted-source instructions](https://docs.digitalocean.com/products/databases/postgresql/how-to/secure/)
explain where to obtain those values. Its
[supported extensions](https://docs.digitalocean.com/products/databases/postgresql/details/supported-extensions/)
include `fuzzystrmatch` and `pg_trgm`. Confirm availability and permissions on your
chosen service before loading the schema. Managed users are not unrestricted
PostgreSQL superusers; the schema's extension creation and comments must succeed
with the selected credentials. Do not ignore permission errors during bootstrap.

On the server, install the downloaded CA file and mount it read-only into the app.
This file is a public trust certificate, not a database password. The path in the
connection URL must be the path **inside the container**.

```sh
HF_DB_CERT_DIR="/var/lib/dokku/data/storage/$HF_APP-db-cert"
install -d -m 0755 "$HF_DB_CERT_DIR"
install -m 0644 /path/to/downloaded-ca.crt "$HF_DB_CERT_DIR/ca.crt"
dokku storage:mount "$HF_APP" "$HF_DB_CERT_DIR:/app/db-cert:ro"
```

Build the URI using your provider's actual database/user/host/port. URL-encode
special characters in usernames and passwords. The example below is a template;
replace every placeholder before setting it.

```sh
dokku config:set --no-restart "$HF_APP" \
  DATABASE_URL='postgresql://USER:URL_ENCODED_PASSWORD@CLUSTER_HOST:PORT/community_hf?sslmode=verify-full&sslrootcert=/app/db-cert/ca.crt'
```

`verify-full` verifies the server certificate and hostname as well as encrypting
the connection. Keep the CA file available to deployment tasks, one-off commands,
and the running app. Providers using public certificate authorities may require a
different trust configuration; this example specifically uses a downloaded CA.
The application image includes a PostgreSQL 15 command-line client, so do not copy instructions
requiring newer client features without checking compatibility. Continue with
step 4 and option B in step 5. This managed-cluster path is not yet live-tested.

## 4. Configure the application

Set site identity and fresh secrets before the first deploy. This example generates
two independent values on the host. These are application secrets, not your
administrator login password. Keep them in a password manager or another secure
backup along with your server credentials; retain the same values during updates.
Do not enable shell tracing when handling them.

```sh
HF_SESSION_SECRET=$(openssl rand -hex 64)
HF_DEVISE_SECRET=$(openssl rand -hex 64)
dokku config:set --no-restart "$HF_APP" \
  RAILS_ENV=production RACK_ENV=production \
  APP_NAME='Our Community HistoryForge' BASE_URL="$HF_DOMAIN" \
  SECRET_KEY_BASE="$HF_SESSION_SECRET" DEVISE_SECRET_KEY="$HF_DEVISE_SECRET" \
  WEBAUTHN_ORIGIN="https://$HF_DOMAIN" WEBAUTHN_RP_ID="$HF_DOMAIN"
unset HF_SESSION_SECRET HF_DEVISE_SECRET
```

Option A supplies `DATABASE_URL` through the database link; option B sets it
explicitly. SMTP is the service HistoryForge uses to send email, including
invitations, password resets, and contact messages. Your mail provider supplies
the server name, port, username, and password; these are not necessarily the
credentials you use to sign into your personal mailbox. Configure it before
inviting users. See [configuration](configuration.md)
for the distinction between startup environment variables and administrator settings.
Use your mail provider's actual values. Configure a sender address authorized by
that provider, and verify delivery to an address you control before inviting users.

```sh
dokku config:set --no-restart "$HF_APP" \
  SMTP_HOST='YOUR_SMTP_HOST' SMTP_PORT='587' \
  SMTP_USERNAME='YOUR_SMTP_USERNAME' SMTP_PASSWORD='YOUR_SMTP_PASSWORD'
```

Leave `DISALLOW_INDEXING` unset for a public community site so its record pages
can appear in search results. The existing map-page crawl exclusions still apply;
see [indexing behavior](configuration.md#search-engine-visibility).

## 5. Bootstrap the empty database from the selected image

Do this **only for the empty database created in step 3**. The fresh-install command refuses a database with existing application tables.
It is not an upgrade procedure. Historical migrations can assume existing application data;
loading the release's schema first avoids replaying the entire migration history.
`hf:bootstrap` loads the schema, runs the normal seeds, adds missing 1930
occupation codes, and prompts for your first administrator's login and email.
It prints a generated password; save it securely. Run it from an interactive
terminal. The `-it` Docker option connects that terminal to the setup process.
Subsequent deployments run `db:migrate db:seed` through `app.json`.

Use an image containing `hf:bootstrap`; these new instructions cannot be used
with an older published image that lacks the command.

Download the HistoryForge package using the commands for your database option
below. The second command records the downloaded package's exact identifier in
`HF_IMAGE`. Docker calls this identifier a digest. You do not need to look it up
or type it yourself. Keep the variable set through step 6 so the database and app
use the same version, even if `latest` changes during installation.

Only if you chose a custom image in a private registry, configure Docker login
for this shell and [Dokku registry access](https://dokku.com/docs/advanced-usage/registry/)
for deployments.

### Option A: bootstrap the local Dokku database

The bootstrap container shares the database container's network namespace. Its
connection URL is rewritten to localhost inside that container, avoiding a
public database port and dependence on the host resolving Dokku's database alias.

```sh
docker pull "$HF_IMAGE"
HF_IMAGE=$(docker image inspect --format '{{index .RepoDigests 0}}' "$HF_IMAGE")
HF_DB_CONTAINER=$(dokku postgres:info "$HF_DB" --id)
export DATABASE_URL=$(dokku config:get "$HF_APP" DATABASE_URL)
export SECRET_KEY_BASE=$(dokku config:get "$HF_APP" SECRET_KEY_BASE)
docker run --rm -it --network "container:$HF_DB_CONTAINER" \
  -e DATABASE_URL -e SECRET_KEY_BASE "$HF_IMAGE" /bin/bash -ec '
    export DATABASE_URL="$(ruby -ruri -e '\''u = URI(ENV.fetch("DATABASE_URL")); u.host = "127.0.0.1"; puts u'\'')"
    bundle exec rails hf:bootstrap
  '
unset DATABASE_URL SECRET_KEY_BASE
```

If schema loading fails, inspect the error and the new database before continuing; do not switch to
an existing site's database or force a destructive reset.

### Option B: bootstrap the managed database

Run this on the Dokku server after configuring the managed connection and app
secrets. It uses normal outbound networking and mounts the same CA certificate as
the app. **Do not rewrite the hostname to localhost** for a managed database.
Reestablish `HF_DB_CERT_DIR` if you opened a new shell.

```sh
docker pull "$HF_IMAGE"
HF_IMAGE=$(docker image inspect --format '{{index .RepoDigests 0}}' "$HF_IMAGE")
HF_DB_CERT_DIR="/var/lib/dokku/data/storage/$HF_APP-db-cert"
export DATABASE_URL=$(dokku config:get "$HF_APP" DATABASE_URL)
export SECRET_KEY_BASE=$(dokku config:get "$HF_APP" SECRET_KEY_BASE)
docker run --rm -v "$HF_DB_CERT_DIR:/app/db-cert:ro" \
  -e DATABASE_URL "$HF_IMAGE" /bin/bash -ec '
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "SELECT current_database(), current_user;"
  '
```

Verify the result names the **new site database and intended user**, then initialize it:

```sh
docker run --rm -it \
  -v "$HF_DB_CERT_DIR:/app/db-cert:ro" \
  -e DATABASE_URL \
  -e SECRET_KEY_BASE \
  -e RAILS_ENV=production \
  "$HF_IMAGE" bundle exec rails hf:bootstrap
unset DATABASE_URL SECRET_KEY_BASE
```

If connectivity fails, check the trusted sources, routing, hostname, port, and CA
path. For schema permission failures, inspect the provider's database/schema and
extension permissions. These commands initialize only an empty database, not an
existing site. Both options now continue with the same deployment steps below.

## 6. Deploy once, then enable HTTPS

Deployment starts the downloaded application and connects it to your site
address. First check that it answers over HTTP; then enable HTTPS, which
encrypts connections and lets browsers verify your site's identity.

```sh
dokku ports:set "$HF_APP" http:80:5000
dokku git:from-image "$HF_APP" "$HF_IMAGE"
curl --fail "http://$HF_DOMAIN/check.txt"
```

Expect `simple_check`, which means the application is responding. If deployment
fails or you receive a different response, stop and read the application logs
with `dokku logs "$HF_APP"`. Ordinary pages redirect to HTTPS; this check is
available over HTTP so you can verify startup before obtaining the certificate.

```sh
dokku letsencrypt:set "$HF_APP" email 'YOUR_OPERATOR_EMAIL'
dokku letsencrypt:enable "$HF_APP"
dokku letsencrypt:cron-job --add
curl --fail "https://$HF_DOMAIN/check.txt"
dokku letsencrypt:report "$HF_APP"
```

The [Let's Encrypt plugin](https://github.com/dokku/dokku-letsencrypt) requires a
successful HTTP deployment before issuance. Renewal scheduling is host-wide;
check an existing host's schedule before changing it. All configured domains
must resolve correctly for certificate issuance. Do not bypass certificate
verification to make the rollout pass.

## 7. Sign in and configure your collection

Sign in over HTTPS using the administrator account created in step 5. Your
reference data and account already exist; do not run the fresh-install command
again after deployment.

If setup was interrupted after creating tables, resolve the reported error and
resume the remaining steps in the same temporary container arrangement from
step 5. Replace `hf:bootstrap` with `db:seed`, then `hf:load_occupation_codes`,
then `hf:create_admin`, running only the steps that remain. Seeds and the
occupation loader preserve existing entries. Skip administrator creation if
that account was already created. Never reload the schema to resume setup.

For an already deployed app, missing occupation codes can be added independently:

```sh
dokku run "$HF_APP" bundle exec rails hf:load_occupation_codes
```

This loader preserves existing records and needs
ordinary database write permissions, not privileges to disable foreign keys.
To create an additional administrator, use `dokku run "$HF_APP" bundle exec
rails hf:create_admin` in an interactive session.

In the administrator interface:

1. Create the site's locality with a name and short name; select its primary locality.
2. Set sponsor, contact address, sender address, and default map center.
3. Enable the desired census years for private/public viewing and building entry.
4. Configure the integrations actually used, following [configuration](configuration.md).
5. Begin adding your community's records and verify both authenticated and public views.

## 8. Add records and verify the site

You can enter buildings and census records through the web interface or import
existing census data from CSV. Start with a small group of records so you can
check their fields, addresses, and map locations before importing a larger collection.

For CSV import, prepare a file with the expected column labels and **no `id`
column**. The importer assigns records to the first user, so create the
administrator first. Copy the file to your server, then into the persistent directory:

```sh
install -o 32767 -g 32767 -m 0600 /path/to/census-records.csv "$HF_STORAGE/census-records.csv"
dokku run "$HF_APP" bundle exec rails import:census YEAR=1910 FILE=/app/storage/census-records.csv
```

Replace `1910` with the census year you are importing. Inspect the reported
saved/total counts and resulting records. Import can partially succeed; it is not
a general database restore. Remove the temporary CSV after use. Consult the
[user documentation](https://historyforge.net/documentation) for entering,
reviewing, and publishing your collection.

Before opening the site to contributors and visitors, verify that:

- An administrator can log in and create or edit a building and census record.
- Public searches show the intended records and census years.
- Maps display and records appear at their expected locations.
- Uploaded images and documents can be viewed.
- Invitations, password resets, and contact messages reach their intended recipients.
- HTTPS works, and records and uploaded files remain available after an app restart.

The `/check.txt` endpoint confirms that the application responds, but does not
replace these checks of the features your community will use.

## 9. Backups and ongoing operation

Keep database exports, uploaded files, secrets, and release records backed up
outside the server. A provider snapshot alone does not establish a tested restore.
For **local PostgreSQL**, export on the Dokku host:

```sh
umask 077
dokku postgres:export "$HF_DB" > "$HF_APP-database.dump"
```

For a **managed cluster**, configure the provider's backup retention and restore
settings and test restoring to a separate database or cluster. Dokku's
`postgres:export` applies only to plugin-managed services, not your external
cluster. For a portable logical export, use a PostgreSQL client matching the
server major version (the application image's older `pg_dump` may not work):

```sh
HF_DB_CERT_DIR="/var/lib/dokku/data/storage/$HF_APP-db-cert"
export DATABASE_URL=$(dokku config:get "$HF_APP" DATABASE_URL)
umask 077
docker run --rm -v "$HF_DB_CERT_DIR:/app/db-cert:ro" \
  -e DATABASE_URL postgres:17-bookworm /bin/sh -ec 'pg_dump --dbname="$DATABASE_URL" --format=custom --no-owner --no-acl' \
  > "$HF_APP-database.dump"
unset DATABASE_URL
```

Use that client tag only with a PostgreSQL 17 server; match your selected major
version otherwise. Confirm the export command succeeds before keeping the dump.
Provider backups do not include files uploaded to the application server.

Copy the export and a consistent backup of `HF_STORAGE` to your backup destination.
Choose a schedule and retention policy, and restore into a separate test database
and upload directory before declaring recovery ready. Never import a test backup
over the running site. Record the exact image identifier used for each successful
release. Returning to an earlier version requires that image to remain available;
pulling `latest` again does not retrieve the previous version.
Use [updating and maintaining your site](operating.md) for subsequent updates,
routine checks, and troubleshooting. You can continue using the published
package without downloading the source repository.

## For contributors and operators publishing their own version

### Optional: change the application code

If you want to change how HistoryForge itself works, you will need to learn more
about Docker: how to build an image from your modified source code, test it, and
publish it somewhere your server can download it. A **fork** is your own copy of
the source repository on GitHub; changing that copy does not change the contents
of `dfurber/historyforge:latest`.

Start with the [development guide](../.devcontainer/README.md) to work on the code,
then use the [release guide](deployment.md) to build and publish your own image.
When following the installation steps, set `HF_IMAGE` to the image reference
you published. Community operators can keep the ready-made package name.

### Optional: manage releases for several sites

If you plan to operate several HistoryForge sites, you can keep using the
maintainer's package for all of them. Each site still has its own configuration,
database, and uploaded files.

When you want to publish your own shared version and control which releases you
keep available, create a Docker Hub account and an **image repository**, such as
`yourname/historyforge`. Docker Hub is the registry service; your repository is
the place within it where you publish your HistoryForge images. You do not need
to run a registry server yourself.

You can then build and test a release once, publish it to your repository, try it
on a separate test installation, and deploy that same release to your community sites. They can
all use the same image while keeping their own names, settings, and collections.
This involves learning the Docker build and publishing workflow and taking
responsibility for testing updates and retaining working releases. See
[publishing your own releases](deployment.md#choose-an-image-repository) when
you are ready for that step.
