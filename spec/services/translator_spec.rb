# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Translator do
  describe '#label' do
    it 'translates a label for a simple class' do
      expect(described_class.label(Building, :year_earliest)).to eq('Year Built')
    end

    it 'translates a label that has not been overridden' do
      expect(described_class.label(Census1900Record, :can_read)).to eq('Can Read')
    end

    it 'translates label specific to a census year' do
      expect(described_class.label(Census1880Record, :page_number)).to eq('Page')
    end
  end

  describe '#option' do
    it 'translates a census code' do
      expect(described_class.option(:civil_war_vet, 'ua')).to eq('Union Army')
    end
  end
end
