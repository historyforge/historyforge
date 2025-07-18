# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserGroup, type: :model do
  describe 'role functionality' do
    let(:user_group) { create(:user_group) }
    let(:admin_role) { Role.find_by(name: 'Administrator') }
    let(:editor_role) { Role.find_by(name: 'Editor') }

    it 'can have roles assigned' do
      user_group.add_role(admin_role)
      expect(user_group.has_role?('Administrator')).to be true
      expect(user_group.roles.map(&:name)).to include('Administrator')
    end

    it 'can have multiple roles' do
      user_group.add_role(admin_role)
      user_group.add_role(editor_role)
      expect(user_group.roles.length).to eq(2)
      expect(user_group.has_role?('Administrator')).to be true
      expect(user_group.has_role?('Editor')).to be true
    end

    it 'can remove roles' do
      user_group.add_role(admin_role)
      user_group.add_role(editor_role)
      user_group.remove_role(admin_role)
      expect(user_group.has_role?('Administrator')).to be false
      expect(user_group.has_role?('Editor')).to be true
    end

    it 'handles role_ids assignment' do
      user_group.role_ids = [admin_role.id, editor_role.id]
      expect(user_group.has_role?('Administrator')).to be true
      expect(user_group.has_role?('Editor')).to be true
    end
  end
end
