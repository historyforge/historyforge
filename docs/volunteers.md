# Volunteer applications

The existing `/volunteer` CMS recruitment page links to `/volunteer_applications/new`. A migration replaces the shared Google Form URL in CMS templates, widget data, and rich text without replacing surrounding content.

## Form and storage

`VolunteerApplication` holds the submitted name, email, answers, optional user link, status, and private staff notes. `locality_names` is a PostgreSQL string array populated from the current locality list. `opportunity_interests` is a string array of codes defined by `VolunteerApplication::OPPORTUNITIES`. Locality names remain as submitted if localities are renamed or deleted. There are no volunteer profiles or interest tables.

A CMS page assigned to `VolunteerApplicationsController#new` can place the form with `{{volunteer_form}}`. Without a CMS page, the form appears directly. Form content is excluded from saved CMS previews. The original required fields are name, email, and how the applicant heard about HistoryForge. reCAPTCHA uses the existing configuration when enabled.

## Review and invite

Administrators open **Admin → Volunteer Applications**, review the submission, and record status or notes. **Create / connect user** creates and invites a user or explicitly links an existing account with a matching email. Several applications can link to one user. Public submissions never automatically link accounts.

New accounts copy the applicant name into `User#full_name`, separate from the login username. Full name can be edited on the user page. Existing accounts keep their current details when linked. New users stay disabled until accepting their Devise invitation. An optional group controls permissions; no roles are granted by default. Repeat clicks do not create or invite a second user. Failed email delivery leaves the user linked and offers the existing **Resend Invite** action. Deleting a user preserves their applications.

Run `bundle exec rails db:migrate` to install. Successful submissions email the same configured recipient as the contact form, with the applicant as Reply-To and their answers in the message. Staff edits do not send another notification. Google response import is not included.

## Verification

`bundle exec rspec spec/features/volunteer_application_spec.rb` exercises the browser journey from the recruitment page through submission, admin review, invitation, acceptance, and a fresh login. Request and model coverage lives in `spec/requests/volunteer_applications_spec.rb`, `spec/requests/volunteer_accounts_spec.rb`, and `spec/models/volunteer_application_spec.rb`.

## Intake flags

Each application creates a system flag before the submission email is sent. Non-admins see only “Volunteer Application Submitted” in the flags list and cannot open or act on the flag. Admins can review the application and manually resolve the flag. Successful invitations, resends, and explicit existing-account links resolve the intake flag with the acting administrator and time. Failed delivery leaves it open; other flags are unaffected.
