# Explore HistoryForge

You can work with HistoryForge on your own computer or start a collection for
your community. The setup depends on where you want it to run.

## Work on your own computer

The [development guide](../.devcontainer/README.md) explains how to download the
source and run HistoryForge locally, including an optional Docker-based
workspace. This is the path for working on the code or exploring the application
without renting a server. It requires development tools; we do not yet provide
a desktop installer.

Your browser connects to `http://localhost:3000`. You do not need a public domain,
HTTPS certificate, or search-engine configuration for that local setup.
Development email opens locally for inspection rather than being sent through
a production mail service.

After setup, follow the development guide's initialization commands to load
reference data and create an administrator. Create a locality, enable a census
year, and enter a few buildings and records. The initial data supplies application
settings and reference lists, but no sample community collection.

## Start a collection for your community

Follow [the installation guide](installation.md) to run the published
`dfurber/historyforge:latest` package on a server. You do not need to clone the
repository, build software, or create a Docker Hub account. You will need hosting,
a domain, and access to configure them; the guide explains each requirement.

You can begin with a small collection and invite more people as you get familiar
with the application. Your site's name, localities, census years, and records
are configured through settings and the web interface. They do not require
changes to the application code.

Use the [user documentation](https://historyforge.net/documentation) to learn
about entering, reviewing, and publishing records. Once the site is running,
[ongoing operation](operating.md) covers updates and maintenance.

## Contribute changes

Use the local development environment to make and test code changes. When you
are ready to publish your own version, follow the [build and deployment guide](deployment.md).
That guide also covers testing releases on a separate server installation before
updating live sites.
