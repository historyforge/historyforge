# Update and maintain your HistoryForge site

This guide is for a community site running the published
`dfurber/historyforge:latest` package on Dokku. You do not need to clone the
HistoryForge repository, install development tools on your computer, or publish
an image. For your first installation, use [the installation guide](installation.md).
Contributors publishing code changes should use [the deployment guide](deployment.md).

These update instructions are still being verified on a hosted installation.

## Connect to your site

Use the same SSH connection you used during installation. Your hosting account
has the server address if you need to look it up.

The examples use `community-hf` and `history.example.org`. Replace them with your
site's values. Open a terminal on your computer and connect to the server using
SSH, as you did during installation. All commands below run on that server.

## Update the application

An update replaces the application package. It keeps your database, uploaded
files, and Dokku settings. Database changes included in the release run during
deployment. Check that your [hosting backups](installation.md#9-backups-and-ongoing-operation)
are up to date, read any instructions accompanying the release, and choose a time when
you can check the site afterward. Do not repeat the installation's schema-loading
step on an existing database.

Set your site details in the server terminal:

```sh
HF_APP=community-hf
HF_DOMAIN=history.example.org
```

Download the published package, then deploy that download:

```sh
docker pull dfurber/historyforge:latest &&
HF_IMAGE=$(docker image inspect --format '{{index .RepoDigests 0}}' dfurber/historyforge:latest) &&
dokku git:from-image "$HF_APP" "$HF_IMAGE"
```

Paste this as one block. Each command runs only if the previous one succeeds.
The middle line automatically identifies the version just downloaded; you do
not need to find an identifier on Docker Hub or type one yourself. This lets
Dokku recognize a new version even though the published name is still `latest`.
The approach follows [Dokku's image deployment instructions](https://dokku.com/docs/deployment/methods/image/).
If the downloaded version is already deployed, Dokku may report no change.

If deployment reports an error, stop and follow the troubleshooting section below.
Otherwise check that the app responds:

```sh
curl --fail "https://$HF_DOMAIN/check.txt"
```

Expect `simple_check`. Then open the site in your browser: sign in, search for
known records, view maps and uploaded files, and check the features your community
uses. The small automated check does not exercise those workflows.

## If something does not work

Start with the error from the command that failed. To read recent application
messages, run:

```sh
dokku logs "$HF_APP"
```

| Symptom | What to check first |
| --- | --- |
| The domain does not resolve | Check the domain's DNS A record against the server IP in your hosting account. |
| Another forge appears, or the browser reports a certificate error | Check the Dokku app's domain and HTTPS setup in installation step 6. Pointing DNS at a shared server does not assign the domain to an app. |
| Deployment fails | Keep the deployment output and application logs. Check disk space, memory, and database connection errors before retrying. |
| The app runs but no census records are visible | Check the locality and census visibility settings in the administrator interface. |
| Invitations or password resets do not arrive | Check both the SMTP connection and sender address in the configuration guide, plus the mail provider's delivery logs. |

When asking for help, include the command, error, app name, software versions,
and whether the site still responds. Remove passwords, secret values, personal
data, and database connection URLs from anything you share.

For a failed update, start with the site and its logs; do not rerun fresh-install
commands against your existing database. More involved deployment troubleshooting
is covered in the [advanced deployment guide](deployment.md#advanced-recovery-and-deployment-validation).

## Routine care

- Check the Droplet's Backups page occasionally to confirm automated backups
  are running. A managed database has its own backups.
- Keep the domain registration and hosting account current, and monitor available
  disk space and memory through your provider or server monitoring.
- Check HTTPS certificate renewal and outgoing email periodically.
- Arrange server, Dokku, plugin, and database maintenance as well as application
  updates. Downloading a new HistoryForge image does not update those services.

See [site configuration](configuration.md) for changes to names, email, map
settings, and public visibility. These changes do not require publishing an image.
