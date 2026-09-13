# Try HistoryForge before launching a community site

To try HistoryForge without changing its code, use the maintainer's ready-made
package:

```text
dfurber/historyforge:latest
```

You do not need to build it, publish anything, or create a Docker Hub account.
Docker downloads the package for you when you follow the installation commands.
Docker Hub is simply where the package is stored; you may see it called a
“registry.” The package is called an “image.”

A hosted trial lets you and other people explore the application in a browser.
You will still need a server, a domain, and access to configure them. The
[installation guide](installation.md) explains those requirements and the setup
steps. This package runs the full application; it does not include a collection
of sample records.

## Create a hosted trial site

Follow [the installation guide](installation.md). Keep its package setting:

```sh
HF_IMAGE='dfurber/historyforge:latest'
```

You can choose your site's name, locality, census years, and records through
configuration and the web interface. Those choices do not require custom code.
For a trial, make these additional choices:

- Give the site its own Dokku app, domain, database, database credentials, uploaded
  files, and secrets. It can share a server or managed database cluster with other
  sites, but its data should remain separate.
- Use trial-specific names, such as `historyforge-demo` for the Dokku app and
  `demo.example.org` for the domain.
- Route outgoing mail to a mail capture service: a test mailbox that catches
  application messages instead of delivering them to their named recipients. Empty SMTP settings do not
  reliably disable mail. Confirm that invitations and resets go to the capture
  service before adding accounts with real addresses.
- Set `DISALLOW_INDEXING=true` on this app before its first deployment, as explained
  in [demo indexing](configuration.md#keep-a-public-demo-out-of-search-results).
  The site stays publicly accessible, but asks search engines not to index it.
- Use a small curated or synthetic dataset. Do not start by copying production
  user accounts, password hashes, or integration credentials. No demonstration
  dataset is bundled; document the source and preparation of the records you use.

For importing a CSV, follow [the collection import instructions](installation.md#8-add-records-and-verify-the-site).
Check the saved/total count and inspect the results; import can partially succeed.

## Optional: explore through the development environment

This route involves downloading the source and setting up development tools.
It is useful if you also want to contribute code. Follow the
[development guide](../.devcontainer/README.md) to run HistoryForge locally. It includes an optional Docker-based environment and instructions for
initializing reference data and the first administrator. Your browser connects to `http://localhost:3000`;
you do not need a public domain or an HTTPS certificate for that local setup.

The normal seeds configure the application but do not provide a demonstration
collection. Create a locality, enable a census year, and enter a few buildings and
records to explore the workflows. The [user documentation](https://historyforge.net/documentation)
explains how to work with the collection.

## Optional: try changes to the application code

If you want to change the application itself, you will need to learn more about
Docker and building your own package. Start with the [development guide](../.devcontainer/README.md),
then follow the [release guide](deployment.md) to build and publish your modified
version. Making a copy of the source does not change the ready-made package.

## Optional: use a trial site as a canary

This section is for operators who already manage other HistoryForge sites; it is
not needed just to try the application.

You can use the maintainer's image across your sites, or publish your own shared
version to a Docker Hub repository you control. See
[choosing an image repository](deployment.md#choose-an-image-repository) for
that optional step; the example below uses the maintainer's image.

A canary is a site that receives a release before your active community sites do.
It lets you check application behavior and deployment recovery with less impact
on users. Keep a local record of the initial installation, browser checks, upgrades, and
recovery rehearsal. Verify the features your community sites use before
promoting a release.

After the site is configured, add it first in the operator's ignored
`config/deploy.json`, using its actual SSH alias, app name, and HTTPS URL. Give the
inventory entry a name such as `demo`. Initially, select that entry alone:

```sh
docker pull dfurber/historyforge:latest
HF_RELEASE=$(docker image inspect --format '{{index .RepoDigests 0}}' dfurber/historyforge:latest)
bin/deploy "$HF_RELEASE" demo
```

Run this on the workstation with Docker and the deployment scripts installed.
The commands download the current package and look up its exact identifier
(called a digest) for you. Save `HF_RELEASE`: after browser and recovery checks
pass, use that same value when deploying to explicitly selected community sites.
Do not download `latest` again between testing and deploying the tested release.

Putting the canary first only gates subsequent deployments on the HTTP health
check. The script does not pause for manual QA. Select the canary alone whenever
you need time to review a release before other sites receive it.

A canary sharing an application server or database cluster still shares resources
with the other sites. Account for its memory, CPU, storage, and connection usage;
do not run load tests on shared infrastructure as part of ordinary acceptance.
