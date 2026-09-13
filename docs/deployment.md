# Building and deploying HistoryForge

For a new site, start with [first installation](installation.md). This guide covers
the contributor and maintainer workflow: building images, publishing releases,
and deploying to one or several already-provisioned installations. If you run
the published package for your community, use [updating your site](operating.md);
that path needs no repository checkout.

The root Dockerfile builds this checkout, including production assets. It does
not download the maintainer's application image. Docker with Buildx is required.

## Choose an image repository

You can run one or several sites using `dfurber/historyforge:latest`, as described
in the [installation guide](installation.md). If you want to distribute your own
version across your sites, publish images under an account you control.

For Docker Hub, create an account and an image repository named `historyforge`.
If your account name is `yourname`, the image repository will be
`yourname/historyforge`. Docker Hub hosts the **registry**; the **repository**
holds the versions of your application within it. There is no separate registry
server for you to install or maintain. In the examples below, replace
`your-registry/historyforge` with your actual repository name.

On the computer where you will build and publish releases, authenticate with:

```sh
docker login
```

Owning the repository lets you distribute shared code changes and retain the
releases your sites depend on. You also take responsibility for testing updates
and maintaining those images. Keep known working releases available for recovery.
If you choose a private repository, each deployment host also needs credentials
to download from it.

You do not need a separate image repository for every site. Build and test one
release, publish it once, and deploy its exact identifier (the **digest**) first
to a canary and then to the other sites. Each site's configuration, database,
secrets, and uploaded files stay outside the image and remain separate. The
following sections explain how to build, publish, and roll out those releases.

## Build your own application

```sh
bin/image-build historyforge:local
bin/image-smoke historyforge:local
```

The default target is linux/amd64, matching the existing production hosts. Set
`PLATFORM=linux/arm64` when building for an ARM server. The smoke check validates compiled assets and the runtime user, starts a disposable
PostgreSQL 17 container, loads the schema, boots the actual runtime image, and
requests `/check.txt`. It removes the temporary containers, database volume, and
network afterward. This verifies startup with a fresh schema, not all application
workflows or migrations against existing production data.

The deployment script has isolated failure-path checks: run
`bin/deploy-test` without contacting any servers. It requires Python 3 and Ruby,
but no additional Python packages, Docker, or running Rails application.

Supply `DATABASE_URL` and `SECRET_KEY_BASE` at runtime. Persist `/app/storage`
and any legacy upload/map directories your installation uses. The application
runs as UID/GID 32767, preserving the existing fleet's ownership convention.
Prepare mounted-directory permissions accordingly. The container listens on
port 5000 and expects an HTTPS-terminating proxy for normal application traffic.
For a new installation, follow the [schema bootstrap and initialization sequence](installation.md#5-bootstrap-the-empty-database-from-the-selected-image)
before the first Dokku deployment. Do not use schema loading to upgrade an existing database. Never use the smoke test's
dummy secret for a real installation.

## Publish a release

Run the application tests (`bin/check`, or the development guide's test commands)
and commit the release first. Authenticate to your chosen container registry.

```sh
bin/image-publish your-registry/historyforge
```

Publishing requires all intended changes to be committed, with no uncommitted
changes or untracked files. This ties the published code to its source commit.
It does not update the public `latest` tag. It builds a unique commit/timestamp tag,
loads and smoke-tests the image, then pushes that exact image without rebuilding.
The final output line is its immutable registry digest. Keep successful release
images in the registry; do not prune them merely because a newer release exists.
No production credentials are needed to build or smoke-test an image.

## Configure and deploy a fleet

Copy `config/deploy.example.json` to ignored `config/deploy.json`. Set your image
repository and list installations in rollout order, each with a unique name,
SSH host alias, Dokku app, and public HTTPS URL. The SSH account must be able to
run `dokku` (these scripts expect a shell account, not Dokku's restricted SSH
command interface). Configure registry access on each host if the image is private.

```sh
bin/deploy your-registry/historyforge@sha256:REPLACE_WITH_64_HEX_DIGEST
# Select one installation for initial adoption or recovery:
bin/deploy your-registry/historyforge@sha256:REPLACE_WITH_64_HEX_DIGEST canary
```

For the combined test → build → smoke-test → publish → deploy workflow, use
`bin/deploy --publish [INSTALLATION ...]`. This runs `bin/check` first and requires
a clean checkout before publishing. Explicit digest deployment does not rerun
tests or rebuild the image, which also makes it suitable for recovery.

The first selected installation is the canary. Rollout is intentionally serial:
each Dokku deployment and external health check must pass before continuing.
Failures stop the rollout and produce a nonzero exit code. There is no `--all`
rebuild and no implicit use of `latest`. `bin/deploy-push` is a compatibility alias
for `bin/deploy`; the old `lib/docker/build` command prints migration guidance.

Use `DEPLOY_CONFIG` to select another configuration. State is recorded atomically
in `tmp/deploy/releases.json`, keyed by host/app, with desired, successful and
previous successful digests. Back up this file or set `DEPLOY_STATE_DIR` to a
persistent operator-owned directory. All runs from the same state directory are
locked against overlap. Use one deployment coordinator: this local lock does not
coordinate independent machines or manual Dokku commands. Dokku's own deployment
locking still applies on the server.

A first deployment has no recorded previous release. Before migration, record and
retain each existing working image separately. An external verification failure
can occur after Dokku has switched traffic; the recorded successful release is
therefore the last *verified* release, not a guarantee of what is currently running.
Inspect the server before recovery. A rerun of an identical digest may be a Dokku
no-op; it is not a substitute for repairing missing local image state.

## Recovery and adoption

Redeploy an explicitly selected retained digest to the affected installation with
`bin/deploy`. Do not rebuild old source and assume it produces the same image.
If Dokku reports a missing app image or an identical-image deployment is skipped,
inspect the app repository/image state and use the appropriate Dokku rebuild or
recovery procedure. Image deployment still uses Dokku's lifecycle and is not a
proven fix for issue dokku/dokku#9034.

The existing app.json predeploy hook runs migrations and seeds. Keep migrations
compatible with both old and new application versions and seeds repeatable.
Image rollback does not roll back the database. Back up databases independently.

Before fleet adoption, use a nonproduction installation to verify Procfile and
app.json extraction, runtime configuration, port 5000, storage permissions,
migrations, successful deployment, a failed candidate, and recovery to a retained
release. Ensure the host has enough memory to run old and candidate processes at
once. Investigate startup logs and OOM evidence before changing health timeouts.

This change prepares the workflow; it does not change server configuration,
publish an image, or migrate any live installation automatically.
