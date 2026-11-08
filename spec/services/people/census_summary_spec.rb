# frozen_string_literal: true

require 'active_support/all'
require_relative '../../../app/services/people/census_occupation'
require_relative '../../../app/services/people/census_continuity'
require_relative '../../../app/services/people/census_summary'
require_relative '../../../app/services/people/census_narrative_evidence'
require_relative '../../../app/services/people/census_household'

RSpec.describe People::CensusSummary do
  let(:observation) do
    Struct.new(:year, :name, :person_id, :locality, :locality_id, :city, :street_name, :street_address, :street_house_number,
               :family_id, :relation_to_head, :fellows, :ward, :building_id, :dwelling_number, :page_number,
               :page_side, :occupation, :industry, :attended_school, :age, :pob, :state, keyword_init: true) do
      def field_for(field)
        public_send(field)
      end
    end
  end
  let(:caroline) { Data.define(:short_name).new('Caroline') }

  def summarize(*records, name: 'Frances Aagaard', sex: 'F', readable: ->(_record) { true })
    households = records.index_with { |record| People::CensusHousehold.call(record:, readable:) }
    observations = People::CensusNarrativeEvidence.call(records:, households:)
    described_class.call(name:, sex:, observations:)
  end

  def residence(year, address, number: '12', **attributes)
    observation.new(year:, street_name: 'Main', street_house_number: number, street_address: address,
                    locality: caroline, **attributes)
  end

  it 'states a shared address once and retains both dated sources when other facts differ' do
    earlier = residence(1910, '12 Main St', occupation: 'Clerk')
    later = residence(1920, '12 Main St', occupation: 'Teacher')

    result = summarize(earlier, later)

    expect(result.paragraph).to include('was recorded at 12 Main St in Caroline in both 1910 and 1920')
    expect(result.paragraph.scan('12 Main St').size).to eq(1)
    expect(result.paragraph).to include('In 1910, she was recorded with the occupation “Clerk”',
                                        'In 1920, she was recorded with the occupation “Teacher”')
    expect(result.sources).to eq([earlier, later])
  end

  it 'matches address formatting variants while displaying the original transcription' do
    earlier = residence(1910, '12 Main Street, Apt. 2')
    later = residence(1920, ' 12  MAIN ST. Apartment 2 ')

    result = summarize(earlier, later)

    expect(result.paragraph).to eq('Frances Aagaard was recorded at 12 Main Street, Apt. 2 in Caroline in both 1910 and 1920.')
    expect(result.sources).to eq([earlier, later])
  end

  it 'keeps different house and apartment numbers distinct' do
    earlier = residence(1910, '12 Main St Apt. 2')
    later = residence(1920, '14 Main St Apt. 2', number: '14')

    expect(summarize(earlier, later).paragraph).to include('In 1910, Frances Aagaard lived at 12 Main St Apt. 2',
                                                         'In 1920, she lived at 14 Main St Apt. 2')
    later.street_house_number = '12'
    later.street_address = '12 Main St Apt. 3'
    expect(summarize(earlier, later).paragraph).to include('In 1920, she lived at 12 Main St Apt. 3')
  end

  it 'does not combine addresses across a record with no address' do
    earlier = residence(1910, '12 Main St')
    missing = observation.new(year: 1920)
    later = residence(1930, '12 Main St')

    result = summarize(earlier, missing, later)

    expect(result.paragraph).not_to include('in both')
    expect(result.sources).to eq([earlier, later])
  end

  it 'does not treat a road without a house number as a matching address' do
    earlier = residence(1910, 'Main St', number: nil)
    later = residence(1920, '12 Main St')

    expect(summarize(earlier, later).paragraph).to include('lived on Main St', 'lived at 12 Main St')
  end

  it 'reports the repeated address before a later change and cites all three records' do
    earlier = residence(1910, '12 Main St')
    middle = residence(1920, '12 Main St')
    later = residence(1930, '14 Main St', number: '14')

    result = summarize(later, earlier, middle)

    expect(result.paragraph).to include('at 12 Main St in Caroline in both 1910 and 1920',
                                        'In 1930, she lived at 14 Main St')
    expect(result.sources).to eq([earlier, middle, later])
  end

  it 'states the same occupation once when residences change' do
    earlier = residence(1910, '12 Main St', occupation: 'Teacher', industry: 'School')
    later = residence(1920, '14 Main St', number: '14', occupation: 'teacher', industry: 'School')

    result = summarize(earlier, later)

    expect(result.paragraph).to include('occupation “Teacher” and industry “School” in both 1910 and 1920',
                                        'lived at 12 Main St', 'lived at 14 Main St')
    expect(result.paragraph.scan(/“teacher”/i).size).to eq(1)
    expect(result.sources).to eq([earlier, later])
  end

  it 'combines Doctor and Physician only in the same explicit medical context' do
    earlier = observation.new(year: 1910, occupation: 'Doctor', industry: 'Hospital')
    later = observation.new(year: 1920, occupation: 'Physician', industry: 'Hospital')

    expect(summarize(earlier, later).paragraph).to include('occupation “Physician” and industry “Hospital” in both 1910 and 1920')

    earlier.industry = nil
    expect(summarize(earlier, later).paragraph).to include('occupation “Doctor”', 'occupation “Physician”')
    earlier.industry = 'Clinic'
    expect(summarize(earlier, later).paragraph).not_to include('in both')

    earlier.industry = later.industry = 'Medical'
    expect(summarize(earlier, later).paragraph).to include('occupation “Physician” and industry “Medical” in both 1910 and 1920')
  end

  it 'matches familiar compound spellings and keeps the recorded spelling in the summary' do
    earlier = observation.new(year: 1910, occupation: 'Book Keeper')
    later = observation.new(year: 1920, occupation: 'Bookkeeper')

    expect(summarize(earlier, later).paragraph).to include('occupation “Book Keeper” in both 1910 and 1920')
  end

  it 'combines Attorney and Lawyer and preserves their separately recorded industries' do
    earlier = observation.new(year: 1910, occupation: 'Attorney', industry: 'General Practice')
    later = observation.new(year: 1920, occupation: 'Lawyer', industry: 'District Office')

    expect(summarize(earlier, later).paragraph).to include('occupation “Attorney” in both 1910 and 1920',
                                                         'industry “General Practice”', 'industry “District Office”')
  end

  it 'combines Teacher and Teaching in the same education setting without folding in Professor' do
    earlier = observation.new(year: 1910, occupation: 'Teaching', industry: 'Cornell University')
    later = observation.new(year: 1920, occupation: 'Teacher', industry: 'Cornell University')

    expect(summarize(earlier, later).paragraph).to include('occupation “Teacher” and industry “Cornell University” in both 1910 and 1920')

    earlier.occupation = 'Professor'
    expect(summarize(earlier, later).paragraph).to include('occupation “Professor”', 'occupation “Teacher”')
    earlier.occupation = 'Teaching'
    earlier.industry = nil
    expect(summarize(earlier, later).paragraph).not_to include('in both')
  end

  it 'combines School Teacher and Teacher only in the same school setting' do
    earlier = observation.new(year: 1910, occupation: 'School Teacher', industry: 'Public School')
    later = observation.new(year: 1920, occupation: 'Teacher', industry: 'Public School')

    expect(summarize(earlier, later).paragraph).to include('occupation “Teacher” and industry “Public School” in both 1910 and 1920')

    earlier.industry = later.industry = 'University'
    expect(summarize(earlier, later).paragraph).not_to include('in both')
  end

  it 'retains different industries when the occupation is the same' do
    earlier = observation.new(year: 1910, occupation: 'Clerk', industry: 'Hardware Store')
    later = observation.new(year: 1920, occupation: 'Clerk', industry: 'Railroad')

    expect(summarize(earlier, later).paragraph).to eq(
      'Frances Aagaard was recorded with the occupation “Clerk” in both 1910 and 1920. ' \
      'In 1910, she was recorded in the industry “Hardware Store”. ' \
      'In 1920, she was recorded in the industry “Railroad”.'
    )
  end

  it 'connects residence, household, and schooling across censuses and cites the head records' do
    head_1940 = observation.new(year: 1940, name: 'Andrew Aagaard', person_id: 42, relation_to_head: 'Head')
    head_1950 = observation.new(year: 1950, name: 'Andrew Aagaard', person_id: 42, relation_to_head: 'Head')
    child = observation.new(year: 1940, age: 7, locality: caroline, locality_id: 1, family_id: '148',
                            street_name: 'Coddington', street_address: 'Coddington Rd',
                            relation_to_head: 'Daughter', fellows: [head_1940], attended_school: true, occupation: 'None')
    teenager = observation.new(year: 1950, locality: caroline, locality_id: 1, family_id: '152',
                               street_name: 'Coddington', street_address: '1784 Coddington Rd', street_house_number: '1784',
                               relation_to_head: 'Daughter', fellows: [head_1950], occupation: 'Student Senior in High School')

    result = summarize(teenager, child)

    expect(result.paragraph).to include('At seven, Frances Aagaard lived on Coddington Rd in Caroline',
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

  it 'does not turn an ambiguous household into a definite claim by filtering out a head' do
    visible_head = observation.new(year: 1940, name: 'Andrew Aagaard', relation_to_head: 'Head')
    hidden_head = observation.new(year: 1940, name: 'Another Head', relation_to_head: 'Head')
    child = observation.new(year: 1940, family_id: '148', locality_id: 1, relation_to_head: 'Daughter',
                            fellows: [visible_head, hidden_head], attended_school: true)
    readable = ->(record) { record != hidden_head }

    household = People::CensusHousehold.call(record: child, readable:)

    expect(household.fellows).to eq([visible_head])
    expect(summarize(child, readable:).sources).to eq([child])
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
