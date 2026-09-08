# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Password sessions', type: :request do
  let(:user) { create(:administrator) }

  it 'persists a real password login across requests and revokes it on logout' do
    post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } }
    expect(response).to have_http_status(:redirect)
    get users_path
    expect(response).to have_http_status(:ok)

    delete destroy_user_session_path
    get users_path
    expect(response).to redirect_to(root_path)
    expect(flash[:error]).to include('Please sign in again')
  end

  it 'does not establish a session with a wrong password' do
    post user_session_path, params: { user: { email: user.email, password: 'wrong-password' } }
    get users_path
    expect(response).to redirect_to(root_path)
  end

  it 'does not establish a session for a disabled user' do
    user.update!(enabled: false)
    post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } }
    get users_path
    expect(response).to redirect_to(root_path)
  end
end
