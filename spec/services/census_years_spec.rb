# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CensusYears do
  describe '#lte' do
    it 'returns census years before the given year' do
      expect(CensusYears.lte(1890)).to include(1880)
    end
    it 'returns census year equal to the given year' do
      expect(CensusYears.lte(1900)).to include(1900)
    end
    it 'does not return census years after the given year' do
      expect(CensusYears.lte(1890)).not_to include(1900)
    end
  end
end
