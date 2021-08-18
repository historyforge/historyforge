require 'rails_helper'

RSpec.describe Translator do
  describe '#label' do
    it 'translates a label for a simple class' do
      expect(Translator.label(Building, :year_earliest)).to eq('Year Built')
    end
    it 'translates a label that has not been overridden' do
      expect(Translator.label(Census1900Record, :can_read)).to eq('Can Read')
    end
    it 'translates label specific to a census year' do
      expect(Translator.label(Census1880Record, :page_number)).to eq('Page')
    end
  end

  describe '#option' do
    it 'translates a census code' do
      expect(Translator.option(:civil_war_vet, 'ua')).to eq('Union Army')
    end
  end
end
