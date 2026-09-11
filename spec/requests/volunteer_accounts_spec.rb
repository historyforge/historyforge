# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Volunteer user accounts', type: :request do
  let!(:volunteer) { VolunteerApplication.create!(name: 'Alex Volunteer', email: 'alex@example.org', how_heard: 'Friend') }
  let(:attributes) { { login: 'Alex Volunteer' } }

  def sign_in_admin
    admin = create(:administrator)
    post user_session_path, params: { user: { email: admin.email, password: 'b1g_sekrit' } }
    admin
  end

  it 'restricts both reviewing and creating links to administrators' do
    get new_volunteer_application_account_path(volunteer)
    expect(response).to redirect_to(root_path)
    expect do
      post volunteer_application_account_path(volunteer), params: { volunteer_account: attributes }
    end.not_to change(User, :count)
    user = create(:active_user)
    post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } }
    post volunteer_application_account_path(volunteer), params: { volunteer_account: attributes }
    expect(response).to redirect_to(root_path)
    expect(volunteer.reload.user).to be_nil
  end

  it 'prepopulates the invitation form and creates, links, and sends exactly one invitation' do
    admin = sign_in_admin
    get new_volunteer_application_account_path(volunteer)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Alex Volunteer', 'alex@example.org', 'Create user and send invitation')
    expect do
      post volunteer_application_account_path(volunteer), params: { volunteer_account: attributes.merge(roles_mask: 1, email: 'other@example.org') }
    end.to change(User, :count).by(1).and change(ActionMailer::Base.deliveries, :size).by(1)
    user = volunteer.reload.user
    expect(response).to redirect_to(user_path(user))
    expect(user.email).to eq(volunteer.email)
    expect(user.invited_by).to eq(admin)
    expect(volunteer.flags.sole.reload.resolved_by).to eq(admin)
    expect(user.roles).to be_empty
    expect(user).not_to be_enabled
    expect(user.invitation_token).to be_present
    expect(user.volunteer_applications).to include(volunteer)
    expect(user.full_name).to eq(volunteer.name)
    expect do
      post volunteer_application_account_path(volunteer), params: { volunteer_account: attributes }
    end.not_to change(ActionMailer::Base.deliveries, :size)
    expect(User.where(email: volunteer.email).count).to eq(1)
  end

  it 'uses a working Devise invitation that enables the linked user on acceptance' do
    sign_in_admin
    post volunteer_application_account_path(volunteer), params: { volunteer_account: attributes }
    mail = ActionMailer::Base.deliveries.last
    body = (mail.text_part || mail).body.decoded
    token = body.match(/invitation_token=([^\s]+)/)[1]
    recipient = open_session
    recipient.put '/u/invitation', params: { user: { invitation_token: token, password: 'b1g_sekrit', password_confirmation: 'b1g_sekrit' } }
    expect(volunteer.reload.user.invitation_accepted_at).to be_present
    expect(volunteer.user).to be_enabled
  end

  it 'retains validation errors without creating or linking a user or sending mail' do
    sign_in_admin
    expect do
      post volunteer_application_account_path(volunteer), params: { volunteer_account: { login: 'x' } }
    end.not_to change(User, :count)
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('too short')
    expect(volunteer.reload.user).to be_nil
  end

  it 'requires explicit linking when an account already uses the email' do
    user = create(:active_user, email: volunteer.email)
    before = user.attributes
    sign_in_admin
    get new_volunteer_application_account_path(volunteer)
    expect(response.body).to include('Link existing user')
    expect(response.body).not_to include('Create user and send invitation')
    expect do
      post volunteer_application_account_path(volunteer), params: { volunteer_account: attributes }
    end.not_to change(User, :count)
    expect(response).to have_http_status(:unprocessable_content)
    expect(volunteer.reload.user).to be_nil
    expect do
      post volunteer_application_account_path(volunteer), params: { volunteer_account: { user_id: user.id } }
    end.not_to change(ActionMailer::Base.deliveries, :size)
    expect(volunteer.reload.user).to eq(user)
    expect(user.reload.attributes).to eq(before)
    expect(volunteer.flags.sole).to be_resolved
  end

  it 'rejects a different email but allows multiple applications to link to the same user' do
    sign_in_admin
    user = create(:active_user)
    post volunteer_application_account_path(volunteer), params: { volunteer_account: { user_id: user.id } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(volunteer.reload.user).to be_nil
    matching = create(:active_user, email: volunteer.email)
    other = VolunteerApplication.create!(name: 'Earlier application', email: volunteer.email, how_heard: 'Friend', user: matching)
    post volunteer_application_account_path(volunteer), params: { volunteer_account: { user_id: matching.id } }
    expect(response).to redirect_to(user_path(matching))
    expect(other.reload.user).to eq(matching)
    expect(volunteer.reload.user).to eq(matching)
  end

  it 'keeps the linked account and offers resend when delivery fails' do
    sign_in_admin
    allow_any_instance_of(User).to receive(:deliver_invitation).and_raise(Net::SMTPFatalError.new('Delivery failed'))
    post volunteer_application_account_path(volunteer), params: { volunteer_account: attributes }
    expect(response).to redirect_to(user_path(volunteer.reload.user))
    follow_redirect!
    expect(response.body).to include('could not be sent', 'Resend Invite')
    expect(volunteer.flags.sole).not_to be_resolved
    post volunteer_application_account_path(volunteer), params: { volunteer_account: attributes }
    expect(volunteer.flags.sole.reload).not_to be_resolved
    allow_any_instance_of(User).to receive(:deliver_invitation).and_call_original
    put resend_invitation_user_path(volunteer.user)
    expect(volunteer.flags.sole.reload).to be_resolved
  end

  it 'preserves the application when its user is deleted' do
    user = create(:active_user)
    volunteer.update!(user: user)
    user.destroy!
    expect(volunteer.reload.user_id).to be_nil
  end
end
