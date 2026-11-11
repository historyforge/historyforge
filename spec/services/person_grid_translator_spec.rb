# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonGridTranslator do
  let!(:primary_match) { create(:person, first_name: 'Alice', last_name: 'Brown') }
  let!(:variant_match) { create(:person, first_name: 'William', last_name: 'Gray') }

  before do
    variant_match.names.create!(first_name: 'William', last_name: 'Browne')
  end

  def translate(**params)
    described_class.new(PersonSearch.generate(params:))
  end

  it 'shows See across pages when a later result matches a variant' do
    filters = { names_last_name_start: 'Brown' }
    first_page = translate(s: filters, from: 0, to: 1)
    second_page = translate(s: filters, from: 1, to: 2)

    expect(first_page.column_def.map { |column| column[:field] }.first(2)).to eq(%w[name see_name])
    expect(first_page.row_data.to_a).to match([a_hash_including(name: { name: 'Brown, Alice', reviewed: true, id: primary_match.id })])
    expect(first_page.row_data.first).not_to have_key(:see_name)
    expect(second_page.row_data.to_a).to match([
      a_hash_including(name: { name: 'Browne, William', reviewed: true, id: variant_match.id }, see_name: 'Gray, William'),
    ])
  end

  it 'omits See when only primary names match or when no name filter is applied' do
    [translate(s: { names_last_name_eq: 'Gray' }), translate].each do |grid|
      expect(grid.column_def.map { |column| column[:field] }).not_to include('see_name')
    end
  end
end
