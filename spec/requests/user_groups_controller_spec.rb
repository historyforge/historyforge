# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserGroupsController', type: :request do
  include DeviseRequestSpecHelpers

  let(:admin) { create(:user, :with_administrator_role, enabled: true) }
  let(:role1) { Role.find_by(name: 'Administrator') }
  let(:role2) { Role.find_by(name: 'Editor') }

  before do
    sign_in admin
  end

  describe 'POST /user_groups' do
    it 'creates a user group with roles' do
      expect {
        post user_groups_path, params: {
                                 user_group: {
                                   name: 'Test Group',
                                   role_ids: [role1.id, role2.id],
                                 },
                               }
      }.to change(UserGroup, :count).by(1)
      group = UserGroup.last
      expect(group.role_names).to include('Administrator', 'Editor')
    end
  end

  describe 'PATCH /user_groups/:id' do
    let!(:group) { create(:user_group, name: 'Old Group') }
    it 'updates the roles of a user group' do
      patch user_group_path(group), params: {
                                      user_group: {
                                        name: 'Updated Group',
                                        role_ids: [role2.id],
                                      },
                                    }
      group.reload
      expect(group.name).to eq('Updated Group')
      expect(group.role_names).to eq(['Editor'])
    end
  end
end
