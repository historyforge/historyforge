# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RolesController, type: :request do
  include DeviseRequestSpecHelpers

  let(:admin) { create(:user, :with_administrator_role, enabled: true) }
  let(:user_group) { create(:user_group) }
  let(:user) { create(:user, group: user_group, enabled: true) }
  let(:role1) { Role.find_by(name: 'Administrator') }
  let(:role2) { Role.find_by(name: 'Editor') }

  before do
    sign_in admin
  end

  it 'assigns a direct role to a user' do
    put user_role_path(user_id: user.id, id: role2.id)
    user.reload
    expect(user.role_names).to include('Editor')
  end

  it 'removes a direct role from a user' do
    user.add_role(role2)
    delete user_role_path(user_id: user.id, id: role2.id)
    user.reload
    expect(user.role_names).not_to include('Editor')
  end

  it 'does not remove inherited roles from a user' do
    user_group.add_role(role1)
    delete user_role_path(user_id: user.id, id: role1.id)
    user.reload
    # The role should still be present because it's inherited
    expect(user.role_names).to include('Administrator')
  end
end
