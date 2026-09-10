# Security Policy

HistoryForge is open-source software used by multiple organizations and may be deployed in different hosting environments. Security issues in the HistoryForge application should be reported privately so they can be investigated and addressed before public disclosure.

## Reporting a Vulnerability

Please do **not** open a public GitHub issue for a suspected security vulnerability.

Report security issues privately using GitHub's **Security Advisories** feature for this repository.

Include as much of the following information as you can:

- A description of the vulnerability and its potential impact
- Steps to reproduce the issue
- The affected part of HistoryForge
- Any relevant URLs, requests, responses, logs, or screenshots
- The version, commit, or deployment you tested
- Any suggested mitigation or fix, if you have one

Reports do not need to include a complete exploit. A clear description of unexpected or unsafe behavior is useful.

## What to Report

Examples of security issues include:

- Authentication or authorization failures
- Access to data a user should not be able to view or modify
- Privilege escalation
- Cross-site scripting, SQL injection, command injection, or similar application vulnerabilities
- Cross-site request forgery where existing protections are ineffective
- Unsafe file upload or file handling behavior
- Exposure of credentials, secrets, private configuration, or sensitive user information
- Vulnerabilities in HistoryForge APIs or contribution endpoints
- Security problems caused by HistoryForge's handling of third-party libraries or services

Ordinary software bugs, usability problems, data-quality issues, and feature requests should be reported through the normal GitHub issue tracker.

## What Happens After a Report

We will review reports as project capacity allows and will try to:

1. Confirm receipt of the report.
2. Determine whether the issue affects HistoryForge.
3. Assess its severity and likely impact.
4. Develop and test a fix or mitigation.
5. Coordinate disclosure when appropriate.

HistoryForge is a small open-source project rather than a commercial security-response organization, so we cannot guarantee specific response or remediation times. We do ask reporters to give maintainers a reasonable opportunity to investigate and address an issue before publishing details.

## Supported Versions

HistoryForge is actively developed, and security fixes are generally made against the current maintained version of the application.

Older releases and deployments may not receive security patches. Operators of HistoryForge installations are responsible for keeping their application, operating system, database, Ruby environment, dependencies, and other infrastructure reasonably current.

## Individual HistoryForge Installations

A vulnerability in the **HistoryForge software** should be reported to this project.

A security issue affecting only a particular HistoryForge installation — for example, an exposed server, compromised account, incorrect deployment configuration, or organization-specific access problem — should normally be reported to the organization operating that installation.

If you are unsure whether a problem belongs to the application or a particular deployment, report it privately to the HistoryForge project and we can help determine the appropriate next step.

## Responsible Disclosure

We appreciate security researchers and users who report vulnerabilities responsibly.

Please avoid:

- Accessing, modifying, or deleting data beyond what is necessary to demonstrate the issue
- Attempting to gain persistence on a system
- Disrupting HistoryForge services
- Testing against third-party installations without authorization
- Publishing vulnerability details before maintainers have had a reasonable opportunity to respond

Good-faith reports intended to improve the security of HistoryForge are welcome.
