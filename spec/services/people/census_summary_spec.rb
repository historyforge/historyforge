# frozen_string_literal: true

require 'active_support/all'
require_relative '../../../app/services/people/census_summary'

RSpec.describe People::CensusSummary do
  let(:observation) do
    Struct.new(:year, :name, :person_id, :locality, :locality_id, :city, :street_name, :street_address, :street_house_number,
               :family_id, :relation_to_head, :fellows, :ward, :building_id, :dwelling_number, :page_number,
               :page_side, :occupation, :industry, :attended_school, :age, :pob, keyword_init: true) do
      def field_for(field)
        public_send(field)
      end
    end
  end
  let(:caroline) { Data.define(:short_name).new('Caroline') }

  def summarize(*records, name: 'Frances Aagaard', sex: 'F', readable: ->(_record) { true })
    described_class.call(name:, sex:, records:, readable:)
  end

  it 'connects residence, household, and schooling across censuses and cites the head records' do
    head_1940 = observation.new(year: 1940, name: 'Andrew Aagaard', person_id: 42, relation_to_head: 'Head')
    head_1950 = observation.new(year: 1950, name: 'Andrew Aagaard', person_id: 42, relation_to_head: 'Head')
    child = observation.new(year: 1940, locality: caroline, locality_id: 1, family_id: '148',
                            street_name: 'Coddington', street_address: 'Coddington Rd',
                            relation_to_head: 'Daughter', fellows: [head_1940], attended_school: true, occupation: 'None')
    teenager = observation.new(year: 1950, locality: caroline, locality_id: 1, family_id: '152',
                               street_name: 'Coddington', street_address: '1784 Coddington Rd', street_house_number: '1784',
                               relation_to_head: 'Daughter', fellows: [head_1950], occupation: 'Student Senior in High School')

    result = summarize(teenager, child)

    expect(result.paragraph).to include('In 1940, Frances Aagaard lived on Coddington Rd in Caroline',
                                        'was listed as Andrew Aagaard’s daughter',
                                        'In 1950, she lived at 1784 Coddington Rd in Caroline',
                                        'was listed as a high school senior')
    expect(result.paragraph).not_to match(/moved|same house|employed/)
    expect(result.paragraph.scan('Andrew Aagaard').length).to eq(1)
    expect(result.sources).to eq([child, head_1940, teenager])
    expect(summarize(child, teenager)).to eq(result)
  end

  it 'describes dated work observations without inventing an employer or promotion' do
    earlier = observation.new(year: 1940, occupation: 'Laborer', industry: 'Gun Factory')
    later = observation.new(year: 1950, occupation: 'Hand Sander', industry: 'Gun Factory')

    result = summarize(earlier, later, name: 'Andrew Aagaard', sex: 'M')

    expect(result.paragraph).to eq('In 1940, Andrew Aagaard was recorded with the occupation “Laborer” and industry “Gun Factory”. ' \
                                   'In 1950, he was recorded with the occupation “Hand Sander” and industry “Gun Factory”.')
    expect(summarize(earlier, later, sex: nil).paragraph).to include('In 1950, they were recorded')
  end

  it 'omits a household claim and link when the head record is unreadable' do
    head = observation.new(year: 1940, name: 'Andrew Aagaard', relation_to_head: 'Head')
    child = observation.new(year: 1940, family_id: '148', locality_id: 1, relation_to_head: 'Daughter',
                            fellows: [head], attended_school: true)

    result = summarize(child, readable: ->(record) { record != head })

    expect(result.paragraph).not_to include('Andrew Aagaard')
    expect(result.sources).to eq([child])
  end

  it 'does not pick among conflicting observations from the same census year' do
    first = observation.new(year: 1940, occupation: 'Laborer')
    second = observation.new(year: 1940, occupation: 'Hand Sander')

    expect(summarize(first, second)).to be_nil
  end

  it 'omits the story for birth facts, incomplete addresses, and placeholder occupations alone' do
    record = observation.new(year: 1940, age: 7, pob: 'New York', city: 'Caroline', street_name: 'Unknown',
                             street_address: 'Unknown', occupation: 'None')

    expect(summarize(record)).to be_nil
    expect(summarize).to be_nil
  end
end
