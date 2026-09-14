# Advanced: use managed PostgreSQL

The [basic installation guide](installation.md) runs PostgreSQL on the same
Droplet as HistoryForge. That is the simplest starting point. This guide is for
operators who prefer a separate database service or already have one available.
It describes a **new installation**, not moving an existing site's database.
The managed connection and full installation procedure still need hosted verification.

## Why use a managed database?

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
| Maintenance | You manage PostgreSQL along with the server. | Provider manages database infrastructure and includes database backups. |
| Connection | Dokku's database link supplies the connection URL. | You supply the service's connection URL, network access, and TLS trust configuration. |

Local PostgreSQL is a straightforward starting point for a small standalone site.
A managed cluster is useful when you want separate database capacity and less
infrastructure maintenance. This guide covers the managed path; the basic guide covers local PostgreSQL.

## 1. Prepare the server and application

Follow installation steps 1 and 2. In step 3, set the variables and create the
app and storage directory, then stop before **Create the database**. Do not
install the Postgres plugin, create a local database, or link one to this app.
`HF_DB` is unused here; the database name will be part of your connection URL.
Keep the server terminal open with `HF_APP`, `HF_DOMAIN`, `HF_IMAGE`, and
`HF_STORAGE` set.

## 2. Connect the managed database

You do not need the Dokku Postgres plugin for a managed database. Do not create or link a
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
requiring newer client features without checking compatibility.

## 3. Configure the application

Follow [installation step 4](installation.md#4-configure-the-application) for
site identity, secrets, and email. Your database connection is supplied by the
`DATABASE_URL` you just set. Then return here for initialization rather than
following the local database commands in installation step 5.

## 4. Initialize the empty database

Use an image containing `hf:bootstrap`. It loads the schema, runs seeds, adds
occupation codes, and prompts for the first administrator's login and email.
Save the generated password. The command requires an empty database and an
interactive terminal; it is not an upgrade command. The commands below resolve
the downloaded image automatically and keep it in `HF_IMAGE` for deployment.

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
existing site. After successful initialization, continue with
[installation step 6](installation.md#6-deploy-once-then-enable-https) to deploy,
enable HTTPS, and configure your collection. Do not run the local database
initialization commands from installation step 5.

## Backups and maintenance

DigitalOcean Managed PostgreSQL includes automatic database backups, separately
from Droplet backups. Keep Droplet backups enabled for application files and
uploads. See [DigitalOcean's database backup documentation](https://docs.digitalocean.com/products/databases/postgresql/how-to/restore-from-backups/).

Application updates use the same [maintenance guide](operating.md). The database
connection and certificate mount remain configured in Dokku between releases.
