# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'role inheritance from user groups' do
    let(:user) { create(:user) }
    let(:user_group) { create(:user_group) }
    let(:admin_role) { Role.find_by(name: 'Administrator') }
    let(:editor_role) { Role.find_by(name: 'Editor') }
    let(:reviewer_role) { Role.find_by(name: 'Reviewer') }

    before do
      user.update!(group: user_group)
    end

    it 'inherits roles from user group' do
      user_group.add_role(admin_role)
      user_group.add_role(editor_role)

      expect(user.has_role?('Administrator')).to be true
      expect(user.has_role?('Editor')).to be true
      expect(user.role_names).to include('Administrator', 'Editor')
    end

    it 'combines direct and inherited roles' do
      # Add direct role to user
      user.add_role(reviewer_role)

      # Add role to user group
      user_group.add_role(admin_role)

      expect(user.has_role?('Reviewer')).to be true
      expect(user.has_role?('Administrator')).to be true
      expect(user.role_names).to include('Reviewer', 'Administrator')
      expect(user.roles.length).to eq(2)
    end

    it 'deduplicates roles when user has same role as group' do
      user.add_role(admin_role)
      user_group.add_role(admin_role)

      expect(user.role_names).to include('Administrator')
      expect(user.roles.length).to eq(1)
    end

    it 'handles users without a group' do
      user.update!(group: nil)
      user.add_role(admin_role)

      expect(user.has_role?('Administrator')).to be true
      expect(user.role_names).to include('Administrator')
    end

    it 'updates inherited roles when user group roles change' do
      user_group.add_role(admin_role)
      expect(user.has_role?('Administrator')).to be true

      user_group.remove_role(admin_role)
      expect(user.has_role?('Administrator')).to be false
    end
  end
end
