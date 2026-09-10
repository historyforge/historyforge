# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Volunteer applications', type: :request do
  let!(:locality) { create(:locality) }
  let(:attributes) do
    { name: 'Alex Volunteer', email: ' Alex@example.org ', how_heard: 'The library',
      experience: 'yes', experience_details: 'I digitize photographs.',
      locality_names: [locality.name], opportunity_interests: ['media'] }
  end

  it 'renders the public form with database localities and active opportunities' do
    get new_volunteer_application_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(locality.name, 'Finding and describing photographs and other media', 'Submit application')
    expect(response.body).not_to include('Un - Unknown', 'Left blank')
  end

  it 'preserves the existing volunteer recruitment page' do
    Cms::Page.create!(title: 'Citizen Historians Wanted', url_path: '/volunteer', template: '<p>Existing recruitment copy</p><a href="/volunteer_applications/new">Volunteer</a>')
    get '/volunteer'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Existing recruitment copy', 'href="/volunteer_applications/new"')
    expect(response.body).not_to include('Submit application')
  end

  it 'offers the form as a CMS section, including errors, without saving applicant data in CMS previews' do
    page = Cms::Page.create!(title: 'Join us', controller: 'VolunteerApplicationsController', action: 'new',
                            template: '<p>Custom introduction</p>{{volunteer_form}}<p>Custom footer</p>')
    get new_volunteer_application_path
    expect(response.body).to include('Custom introduction', 'Submit application', 'Custom footer')
    expect(response.body.scan('type="submit"').length).to eq(1)
    post volunteer_applications_path, params: { volunteer_application: attributes.merge(how_heard: '') }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('Custom introduction', 'Alex Volunteer', 'checked="checked"')
    expect(page.reload.data.to_json).not_to include('Alex Volunteer', 'alex@example.org', 'authenticity_token')
  end

  it 'saves the application and distinct interests without privileged fields' do
    expect do
      post volunteer_applications_path, params: { volunteer_application: attributes.merge(
        locality_names: ['', locality.name, locality.name], status: 'accepted', staff_notes: 'Injected', user_id: 123
      ) }
    end.to change(VolunteerApplication, :count).by(1)
    expect(response).to redirect_to(thank_you_volunteer_applications_path)
    application = VolunteerApplication.last
    expect(application.email).to eq('alex@example.org')
    expect(application.locality_names).to eq([locality.name])
    expect(application.opportunity_interests).to eq(['media'])
    expect(application.status).to eq('submitted')
    expect(application.staff_notes).to be_nil
    expect(application.user_id).to be_nil
    get thank_you_volunteer_applications_path
    expect(response.body).to include('has been received')
    expect(response.body).not_to include(application.email)
  end

  it 'renders validation errors and retains selections without saving an application' do
    expect do
      post volunteer_applications_path, params: { volunteer_application: attributes.merge(how_heard: '') }
    end.not_to change(VolunteerApplication, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('How heard', 'Alex Volunteer', 'checked="checked"')
  end

  it 'rejects unavailable locality names without writing records' do
    locality.destroy!
    expect do
      post volunteer_applications_path, params: { volunteer_application: attributes }
    end.not_to change(VolunteerApplication, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('no longer available')
  end

  it 'does not modify an existing user with the submitted email' do
    existing = create(:active_user, login: 'Existing person', email: 'alex@example.org')
    post volunteer_applications_path, params: { volunteer_application: attributes }
    expect(existing.reload.name).to eq('Existing person')
    expect(VolunteerApplication.last.user_id).to be_nil
  end

  it 'does not persist an application when spam verification fails' do
    allow_any_instance_of(VolunteerApplicationsController).to receive(:using_recaptcha?).and_return(true)
    allow_any_instance_of(VolunteerApplicationsController).to receive(:verify_recaptcha).and_return(false)
    expect do
      post volunteer_applications_path, params: { volunteer_application: attributes }
    end.not_to change(VolunteerApplication, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('spam verification')
  end

  context 'with an application' do
    let!(:application) do
      VolunteerApplication.create!(name: 'Private Applicant', email: 'private@example.org', how_heard: 'Friend')
    end

    it 'blocks anonymous access to the inbox, details, and updates' do
      get volunteer_applications_path
      expect(response).to redirect_to(root_path)
      get volunteer_application_path(application)
      expect(response).to redirect_to(root_path)
      expect(response.body).not_to include('private@example.org')
      patch volunteer_application_path(application), params: { volunteer_application: { status: 'accepted' } }
      expect(response).to redirect_to(root_path)
      expect(application.reload.status).to eq('submitted')
    end

    it 'blocks signed-in nonadministrators' do
      user = create(:active_user)
      post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } }
      get volunteer_application_path(application)
      expect(response).to redirect_to(root_path)
    end

    it 'lets administrators review applications and update follow-up fields only' do
      user = create(:administrator)
      post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } }
      get volunteer_applications_path
      expect(response.body).to include('Private Applicant')
      get volunteer_application_path(application)
      expect(response).to have_http_status(:ok)
      expect(response.headers['Cache-Control']).to include('no-store')
      patch volunteer_application_path(application), params: { volunteer_application: {
        status: 'contacted', staff_notes: 'Called today', email: 'changed@example.org'
      } }
      expect(response).to redirect_to(volunteer_application_path(application))
      expect(application.reload.status).to eq('contacted')
      expect(application.staff_notes).to eq('Called today')
      expect(application.email).to eq('private@example.org')
      patch volunteer_application_path(application), params: { volunteer_application: { status: 'invalid' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(application.reload.status).to eq('contacted')
    end
  end
end
