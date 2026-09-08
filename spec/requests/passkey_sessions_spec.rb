# frozen_string_literal: true

require 'rails_helper'
require 'webauthn/fake_client'

RSpec.describe 'Passkey sign-in', type: :request do
  let(:user) { create(:user, :active) }
  let(:relying_party) { WebAuthn::RelyingParty.new(allowed_origins: ['https://tompkins.historyforge.net'], name: 'HistoryForge', id: 'tompkins.historyforge.net') }
  let(:client) { WebAuthn::FakeClient.new('https://tompkins.historyforge.net') }
  let!(:passkey) do
    credential = WebAuthn::Credential.from_create(client.create)
    user.passkeys.create!(label: 'Test passkey', external_id: Base64.strict_encode64(credential.raw_id),
                         public_key: credential.public_key, sign_count: credential.sign_count)
  end

  before do
    allow(WebAuthnHelper).to receive(:relying_party).and_return(relying_party)
  end

  it 'signs in a signed-out user with an existing passkey' do
    post new_user_session_challenge_path, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch('userVerification')).to eq('required')
    credential = client.get(challenge: response.parsed_body.fetch('challenge'), user_verified: true)

    post user_session_path, params: { user: { passkey_credential: credential.to_json } },
                           headers: { 'ACCEPT' => 'application/json' }

    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body).to include('success' => true)
    expect(passkey.reload.last_used_at).to be_present
    get users_passkeys_path
    expect(response).to have_http_status(:ok)
  end

  it 'rejects an assertion for a different challenge' do
    post new_user_session_challenge_path, as: :json
    credential = client.get(user_verified: true)

    post user_session_path, params: { user: { passkey_credential: credential.to_json } },
                           headers: { 'ACCEPT' => 'application/json' }

    expect(response).to have_http_status(:unauthorized)
    expect(passkey.reload.last_used_at).to be_nil
  end

  it 'rejects a passkey without user verification' do
    post new_user_session_challenge_path, as: :json
    credential = client.get(challenge: response.parsed_body.fetch('challenge'), user_verified: false)

    post user_session_path, params: { user: { passkey_credential: credential.to_json } },
                           headers: { 'ACCEPT' => 'application/json' }

    expect(response).to have_http_status(:unauthorized)
    expect(passkey.reload.last_used_at).to be_nil
  end

  it 'rejects a disabled account with a valid passkey' do
    user.update!(enabled: false)
    post new_user_session_challenge_path, as: :json
    credential = client.get(challenge: response.parsed_body.fetch('challenge'), user_verified: true)

    post user_session_path, params: { user: { passkey_credential: credential.to_json } },
                           headers: { 'ACCEPT' => 'application/json' }

    expect(response).to have_http_status(:unauthorized)
    get users_passkeys_path, headers: { 'ACCEPT' => 'application/json' }
    expect(response).to have_http_status(:unauthorized)
  end

  it 'still allows password sign-in' do
    post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } },
                           headers: { 'ACCEPT' => 'application/json' }

    expect(response).to have_http_status(:ok), response.body
    expect(response.parsed_body).to include('success' => true)
  end
end
