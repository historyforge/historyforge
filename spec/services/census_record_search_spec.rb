# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CensusRecordSearch do
  let(:locality) { create(:locality) }
  let(:user) { create(:active_user) }

  def build_search(params = {})
    described_class.generate(year: 1870, params:, user:)
  end

  def create_1870_record(page_number:)
    create(:census1870_record,
           locality:,
           page_number:,
           line_number: 1,
           post_office: 'Ithaca',
           city: 'Ithaca',
           county: 'Tompkins',
           state: 'New York',
           first_name: 'John',
           last_name: 'Doe',
           family_id: '1',
           occupation: 'None')
  end

  it 'filters census records by creator' do
    reviewer = create(:administrator)
    creator = create(:active_user)
    match = create_1870_record(page_number: 1)
    match.update!(created_by: creator)
    create_1870_record(page_number: 2)

    search = described_class.generate(year: 1870, user: reviewer, creator_scope: :all, params: { s: { creator_id: creator.id } })

    expect(search.scoped).to contain_exactly(match)
  end

  it 'filters missing and empty institution names separately from populated names' do
    records = [nil, '', 'County Almshouse'].each_with_index.map do |name, index|
      create(:census1850_record, locality:, page_number: 1, line_number: index + 1,
             county: 'Tompkins', state: 'New York', first_name: 'John', last_name: 'Doe',
             family_id: (index + 1).to_s, occupation: 'None', institution_name: name)
    end

    blank_search = described_class.generate(year: 1850, user:, params: { s: { institution_name_blank: '1' } })
    present_search = described_class.generate(year: 1850, user:, params: { s: { institution_name_present: '1' } })

    expect(blank_search.scoped).to contain_exactly(*records.first(2))
    expect(present_search.scoped).to contain_exactly(records.last)
  end

  describe '#max_page_number' do
    before do
      Current.locality_id = locality.id
      create_1870_record(page_number: 250)
    end

    after { Current.reset }

    it 'reflects the highest page number in the database' do
      expect(build_search.s[:page_number_eq]).to be_nil
      expect(build_search.max_page_number).to eq(250)
    end

    it 'includes the selected page when it exceeds the database maximum' do
      expect(build_search(s: { page_number_eq: '300' }).max_page_number).to eq(300)
    end

    it 'returns zero when no records exist' do
      Census1870Record.delete_all
      expect(build_search.max_page_number).to eq(0)
    end
  end

  describe 'page number filter normalization' do
    before { Current.locality_id = locality.id }
    after { Current.reset }

    it 'preserves valid page numbers' do
      search = build_search(s: { page_number_eq: '250' })
      expect(search.s[:page_number_eq]).to eq('250')
    end

    it 'clamps page numbers above the maximum' do
      search = build_search(s: { page_number_eq: '99999' })
      expect(search.s[:page_number_eq]).to eq('10000')
    end

    it 'drops invalid page numbers' do
      search = build_search(s: { page_number_eq: 'abc' })
      expect(search.s[:page_number_eq]).to be_nil
    end
  end

  describe 'income filters' do
    def income_search(year, filters)
      described_class.generate(year:, user:, params: { s: filters }).scoped
    end

    it 'compares 1940 wages numerically and preserves special-code searches' do
      lower = create(:census1940_record, wages_or_salary: '900')
      upper = create(:census1940_record, wages_or_salary: '1000')
      top_coded = create(:census1940_record, wages_or_salary: '5000+')
      legacy_unknown = create(:census1940_record, wages_or_salary: 'Un')
      unknown = create(:census1940_record, wages_or_salary: 'unknown')
      create(:census1940_record, wages_or_salary: '')
      create(:census1940_record, wages_or_salary: nil)

      expect(income_search(1940, wages_or_salary_amount_lt: '1000')).to contain_exactly(lower)
      expect(income_search(1940, wages_or_salary_amount_gteq: '900', wages_or_salary_amount_lteq: '1000'))
        .to contain_exactly(lower, upper)
      expect(income_search(1940, wages_or_salary_in: %w[5000+ Un unknown])).to contain_exactly(top_coded, legacy_unknown, unknown)
    end

    it 'supports amounts and special codes across the 1950 income fields' do
      fields = %i[wages_or_salary_self own_business_self unearned_income_self
                  wages_or_salary_family own_business_family unearned_income_family]
      records = ['900', '1000', '10000+', 'P6'].each_with_index.map do |value, index|
        attributes = fields.index_with(value)
        create(:census1950_record, locality:, page_number: 1, page_side: 'A', line_number: index + 1,
               enum_dist: '1', county: 'Tompkins', state: 'New York', first_name: 'John', last_name: 'Doe',
               family_id: (index + 1).to_s, occupation: 'None', relation_to_head: 'Head', **attributes)
      end

      filters = CensusFiltersGenerator.generate(Jbuilder.new, Census1950FormFields).attributes!
      fields.each do |field|
        expect(filters.fetch("#{field}_amount").fetch('type')).to eq('number')
        expect(filters.fetch(field.to_s).fetch('choices').map(&:last)).to include('10000+')
        expect(income_search(1950, "#{field}_amount_lt" => '1000')).to contain_exactly(records.first)
      end
      expect(income_search(1950, wages_or_salary_self_in: %w[10000+ P6])).to contain_exactly(*records.last(2))
    end
  end
end
