# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Password registration', type: :request do
  let(:signup) do
    { login: 'New Volunteer', email: 'new-volunteer@example.org',
      password: 'b1g_sekrit', password_confirmation: 'b1g_sekrit' }
  end

  it 'requires a password for public signup' do
    expect do
      post user_registration_path, params: { user: signup.merge(password: '', password_confirmation: '') }
    end.not_to change(User, :count)
    expect(response.body).to include("can&#39;t be blank")
  end

  it 'rejects mismatched password confirmation' do
    expect do
      post user_registration_path, params: { user: signup.merge(password_confirmation: 'different-password') }
    end.not_to change(User, :count)
    expect(response.body).to include('Password confirmation')
  end

  it 'requires the current password before changing account credentials' do
    user = create(:active_user)
    post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } }

    put user_registration_path, params: {
      user: { password: 'replacement-password', password_confirmation: 'replacement-password',
              current_password: 'wrong-password' }
    }
    expect(user.reload.valid_password?('b1g_sekrit')).to be(true)
    expect(user.valid_password?('replacement-password')).to be(false)

    put user_registration_path, params: {
      user: { password: 'replacement-password', password_confirmation: 'replacement-password',
              current_password: 'b1g_sekrit' }
    }
    expect(user.reload.valid_password?('replacement-password')).to be(true)
  end
end
