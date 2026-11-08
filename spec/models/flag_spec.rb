# == Schema Information
#
# Table name: flags
#
#  id             :integer          not null, primary key
#  flaggable_type :string
#  flaggable_id   :integer
#  user_id        :integer
#  reason         :string
#  message        :text
#  comment        :text
#  resolved_by_id :integer
#  resolved_at    :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_flags_on_flaggable_type_and_flaggable_id  (flaggable_type,flaggable_id)
#  index_flags_on_resolved_by_id                   (resolved_by_id)
#  index_flags_on_user_id                          (user_id)
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flag, type: :model do
  describe '.safe_flaggable_class' do
    it 'returns the class for legitimate flaggable types' do
      expect(Flag.safe_flaggable_class('Person')).to eq(Person)
      expect(Flag.safe_flaggable_class('Building')).to eq(Building)
      expect(Flag.safe_flaggable_class('Narrative')).to eq(Narrative)
    end

    it 'returns nil for non-flaggable types' do
      expect(Flag.safe_flaggable_class('User')).to be_nil
      expect(Flag.safe_flaggable_class('Address')).to be_nil
    end

    it 'returns nil for blank or nil types' do
      expect(Flag.safe_flaggable_class('')).to be_nil
      expect(Flag.safe_flaggable_class(nil)).to be_nil
    end

    it 'returns nil for non-existent classes' do
      expect(Flag.safe_flaggable_class('NonExistentClass')).to be_nil
    end

    it 'returns nil for classes that exist but are not flaggable' do
      # Assuming User doesn't include Flaggable
      expect(Flag.safe_flaggable_class('User')).to be_nil
    end
  end
end
