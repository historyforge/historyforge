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
