# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Volunteer application flags', type: :request do
  let!(:application) { VolunteerApplication.create!(name: 'Private Applicant', email: 'private@example.org', how_heard: 'Friend') }
  let(:flag) { application.flags.find_by!(reason: 'volunteer_application_submitted') }

  def log_in(user)
    post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } }
  end

  it 'creates one unresolved system flag without applicant details in its message' do
    expect(flag.flagged_by).to be_nil
    expect(flag.message).to eq('Volunteer Application Submitted')
    expect(flag).not_to be_resolved
    application.update!(staff_notes: 'Internal follow-up')
    expect(application.flags.count).to eq(1)
  end

  it 'shows only the generic label to guests and non-admins, without a link or private flag content' do
    flag.update!(message: 'Private staff message', comment: 'Private comment')
    [nil, create(:active_user)].each do |user|
      log_in(user) if user
      get flags_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Volunteer Application Submitted')
      expect(response.body).not_to include('Private Applicant', 'private@example.org', 'Private staff message', 'Private comment', "href=\"#{volunteer_application_path(application)}\"")
      get flag_path(flag)
      expect(response).to redirect_to(root_path)
      patch flag_path(flag), params: { flag: { mark_resolved: '1' } }
      expect(response).to redirect_to(root_path)
      delete flag_path(flag)
      expect(response).to redirect_to(root_path)
      expect(flag.reload).not_to be_resolved
    end
  end

  it 'prevents non-admins from opening or submitting a new flag against an application' do
    log_in(create(:active_user))
    get new_flag_path, params: { flaggable_type: 'VolunteerApplication', flaggable_id: application.id }
    expect(response).to redirect_to(root_path)
    expect do
      post flags_path, params: { flag: { flaggable_type: 'VolunteerApplication', flaggable_id: application.id,
                                        reason: 'duplicate', message: 'Forged' } }
    end.not_to change(Flag, :count)
    expect(response).to redirect_to(root_path)
  end

  it 'allows admins to open the application and manually resolve its flag' do
    admin = create(:administrator)
    log_in(admin)
    get flags_path
    expect(response.body).to include('Private Applicant', "href=\"#{volunteer_application_path(application)}\"")
    get volunteer_application_path(application)
    expect(response.body).to include('Resolve', 'Volunteer Application Submitted')
    patch flag_path(flag), params: { flag: { mark_resolved: '1', comment: 'Will volunteer without an account' } }
    expect(flag.reload).to be_resolved
    expect(flag.resolved_by).to eq(admin)
  end

  it 'auto-resolves only the submission flag' do
    other = application.flags.create!(reason: 'duplicate', message: 'Investigate duplicate')
    admin = create(:administrator)
    application.resolve_submission_flag!(admin)
    expect(flag.reload.resolved_by).to eq(admin)
    expect(other.reload).not_to be_resolved
  end
end
