# frozen_string_literal: true

require 'active_support/all'
require_relative '../../../app/services/people/census_summary'
require_relative '../../../app/services/people/census_summary/occupation'
require_relative '../../../app/services/people/census_summary/continuity'
require_relative '../../../app/services/people/census_summary/evidence'
require_relative '../../../app/services/people/census_household'

RSpec.describe People::CensusSummary do
  let(:observation) do
    Struct.new(:year, :name, :person_id, :person, :locality, :locality_id, :city, :street_name, :street_address, :street_house_number,
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
    observations = People::CensusSummary::Evidence.call(records:, households:)
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

    expect(result.paragraph).to include('lived at 12 Main St in Caroline in both 1910 and 1920')
    expect(result.paragraph.scan('12 Main St').size).to eq(1)
    expect(result.paragraph).to start_with('Frances Aagaard worked as “Clerk” in 1910 and “Teacher” in 1920.')
    expect(result.sources).to eq([earlier, later])
  end

  it 'matches address formatting variants while displaying the original transcription' do
    earlier = residence(1910, '12 Main Street, Apt. 2')
    later = residence(1920, ' 12  MAIN ST. Apartment 2 ')

    result = summarize(earlier, later)

    expect(result.paragraph).to eq('Frances Aagaard lived at 12 Main Street, Apt. 2 in Caroline in both 1910 and 1920.')
    expect(result.sources).to eq([earlier, later])
  end

  it 'keeps different house and apartment numbers distinct' do
    earlier = residence(1910, '12 Main St Apt. 2')
    later = residence(1920, '14 Main St Apt. 2', number: '14')

    result = summarize(earlier, later)
    expect(result.paragraph).to include('at more than one address in Caroline, including 14 Main St Apt. 2 in 1920')
    expect(result.paragraph).not_to include('12 Main St')
    expect(result.sources).to eq([earlier, later])
    later.street_house_number = '12'
    later.street_address = '12 Main St Apt. 3'
    expect(summarize(earlier, later).paragraph).to include('including 12 Main St Apt. 3 in 1920')
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

    expect(summarize(earlier, later).paragraph).to include('on Main St in Caroline, at number 12 in 1920')
  end

  it 'highlights a repeated address over a later one and cites all three records' do
    earlier = residence(1910, '12 Main St')
    middle = residence(1920, '12 Main St')
    later = residence(1930, '14 Main St', number: '14')

    result = summarize(later, earlier, middle)

    expect(result.paragraph).to include('at more than one address in Caroline, including 12 Main St in both 1910 and 1920')
    expect(result.paragraph).not_to include('14 Main St')
    expect(result.sources).to eq([earlier, middle, later])
  end

  it 'states the same occupation once when residences change' do
    earlier = residence(1910, '12 Main St', occupation: 'Teacher', industry: 'School')
    later = residence(1920, '14 Main St', number: '14', occupation: 'teacher', industry: 'School')

    result = summarize(earlier, later)

    expect(result.paragraph).to include('“Teacher” in both 1910 and 1920 (industry “School”)',
                                        'at more than one address in Caroline, including 14 Main St in 1920')
    expect(result.paragraph.scan(/“teacher”/i).size).to eq(1)
    expect(result.sources).to eq([earlier, later])
  end

  it 'combines Doctor and Physician only in the same explicit medical context' do
    earlier = observation.new(year: 1910, occupation: 'Doctor', industry: 'Hospital')
    later = observation.new(year: 1920, occupation: 'Physician', industry: 'Hospital')

    expect(summarize(earlier, later).paragraph).to include('“Physician” in both 1910 and 1920 (industry “Hospital”)')

    earlier.industry = nil
    expect(summarize(earlier, later).paragraph).to include('“Doctor” in 1910', '“Physician” in 1920')
    earlier.industry = 'Clinic'
    expect(summarize(earlier, later).paragraph).not_to include('in both')

    earlier.industry = later.industry = 'Medical'
    expect(summarize(earlier, later).paragraph).to include('“Physician” in both 1910 and 1920')
  end

  it 'matches familiar compound spellings and keeps the recorded spelling in the summary' do
    earlier = observation.new(year: 1910, occupation: 'Book Keeper')
    later = observation.new(year: 1920, occupation: 'Bookkeeper')

    expect(summarize(earlier, later).paragraph).to include('“Book Keeper” in both 1910 and 1920')
  end

  it 'combines Attorney and Lawyer and keeps the specific industry' do
    earlier = observation.new(year: 1910, occupation: 'Attorney', industry: 'General Practice')
    later = observation.new(year: 1920, occupation: 'Lawyer', industry: 'District Office')

    result = summarize(earlier, later)
    expect(result.paragraph).to include('“Attorney” in both 1910 and 1920 (industry “District Office” in 1920)')
    expect(result.paragraph).not_to include('General Practice')
  end

  it 'combines Teacher and Teaching in the same education setting without folding in Professor' do
    earlier = observation.new(year: 1910, occupation: 'Teaching', industry: 'Cornell University')
    later = observation.new(year: 1920, occupation: 'Teacher', industry: 'Cornell University')

    expect(summarize(earlier, later).paragraph).to include('“Teacher” in both 1910 and 1920 (industry “Cornell University”)')

    earlier.occupation = 'Professor'
    expect(summarize(earlier, later).paragraph).to include('“Professor” in 1910', '“Teacher” in 1920')
    earlier.occupation = 'Teaching'
    earlier.industry = nil
    expect(summarize(earlier, later).paragraph).not_to include('in both')
  end

  it 'combines School Teacher and Teacher only in the same school setting' do
    earlier = observation.new(year: 1910, occupation: 'School Teacher', industry: 'Public School')
    later = observation.new(year: 1920, occupation: 'Teacher', industry: 'Public School')

    expect(summarize(earlier, later).paragraph).to include('“Teacher” in both 1910 and 1920 (industry “Public School”)')

    earlier.industry = later.industry = 'University'
    expect(summarize(earlier, later).paragraph).not_to include('in both')
  end

  it 'states an occupation once across differing and missing industries' do
    earlier = observation.new(year: 1910, occupation: 'Clerk', industry: 'Hardware Store')
    middle = observation.new(year: 1920, occupation: 'Clerk', industry: 'Railroad')
    later = observation.new(year: 1930, occupation: 'Clerk')

    result = summarize(earlier, middle, later)

    expect(result.paragraph).to eq(
      'Frances Aagaard worked as “Clerk” in 1910, 1920, and 1930 (industry “Hardware Store” in 1910).'
    )
    expect(result.sources).to eq([earlier, middle, later])
  end

  it 'selects a useful intermediate job without listing the whole work history' do
    clerk = observation.new(year: 1900, occupation: 'Clerk')
    laborer = observation.new(year: 1910, occupation: 'Laborer')
    merchant = observation.new(year: 1920, occupation: 'Merchant', industry: 'Hardware')
    banker = observation.new(year: 1930, occupation: 'Banker')

    result = summarize(clerk, laborer, merchant, banker)

    expect(result.paragraph).to include('“Clerk” in 1900', '“Merchant” in 1920 (industry “Hardware”)', '“Banker” in 1930')
    expect(result.paragraph).not_to include('Laborer')
    expect(result.sources).to eq([clerk, laborer, merchant, banker])
  end

  it 'gives a richer work history room before the residence and household details' do
    first = observation.new(year: 1880, occupation: 'Clerk Store')
    second = observation.new(year: 1900, occupation: 'Merchant And President', industry: 'Hardware And Trust Co Bank')
    third = observation.new(year: 1910, occupation: 'Merchant', industry: 'Hardware')
    fourth = observation.new(year: 1920, occupation: 'President', industry: 'Hardware Co')
    fifth = residence(1930, '12 Main St', occupation: 'Banker')

    result = summarize(first, second, third, fourth, fifth, name: 'Robert H Treman', sex: 'M')
    work, home = result.paragraph.split("\n\n")

    expect(work).to include('“Clerk Store” in 1880', '“Merchant And President” in 1900',
                            '“Merchant” in 1910', '“President” in 1920 (industry “Hardware Co”)', '“Banker” in 1930')
    expect(home).to eq('He lived at 12 Main St in Caroline in 1930.')
    expect(result.sources).to eq([first, second, third, fourth, fifth])
  end

  it 'gives a sparse work observation without filling in missing dimensions' do
    record = observation.new(year: 1910, occupation: 'Clerk', industry: 'Local')

    result = summarize(record)

    expect(result.paragraph).to eq('Frances Aagaard worked as “Clerk” in 1910.')
    expect(result.sources).to eq([record])
  end

  it 'keeps geographic distinctions when nearby localities share a name' do
    place = Data.define(:short_name)
    city = observation.new(year: 1910, locality: place.new('City of Ithaca'), locality_id: 1,
                           street_name: 'Main', street_address: '12 Main St', street_house_number: '12')
    town = observation.new(year: 1920, locality: place.new('Town of Ithaca'), locality_id: 2,
                           street_name: 'Main', street_address: '12 Main St', street_house_number: '12')

    result = summarize(city, town)

    expect(result.paragraph).to include('in City of Ithaca and Town of Ithaca')
    expect(result.paragraph).to include('at 12 Main St in Town of Ithaca in 1920')
    expect(result.sources).to eq([city, town])
  end

  it 'tells Andrew W Aagaard’s work, residence, and family history in separate sentences' do
    head = observation.new(year: 1930, name: 'Webster Barnhart', relation_to_head: 'Head')
    earlier = residence(1930, 'Coddington Rd', number: nil, occupation: 'Laborer', industry: 'University Grounds',
                        locality_id: 1, family_id: '12', relation_to_head: 'Stepson', fellows: [head])
    middle = observation.new(year: 1940, occupation: 'Laborer')
    later = residence(1950, '1784 Coddington Rd', number: '1784', locality_id: 1, occupation: 'Hand Sander', industry: 'Gun Factory')

    result = summarize(later, earlier, middle, name: 'Andrew W Aagaard', sex: 'M')

    expect(result.paragraph).to eq(
      'Andrew W Aagaard worked as “Laborer” in both 1930 and 1940 (industry “University Grounds” in 1930) ' \
      'and “Hand Sander” in 1950 (industry “Gun Factory”). ' \
      'He lived on Coddington Rd in Caroline, at number 1784 in 1950. ' \
      'He was listed as the stepson of Webster Barnhart.'
    )
    expect(result.sources).to eq([earlier, head, middle, later])
  end

  it 'combines repeated job titles around an intervening occupation using only observed years' do
    earlier = observation.new(year: 1910, occupation: 'Clerk')
    middle = observation.new(year: 1920, occupation: 'Teacher')
    later = observation.new(year: 1930, occupation: 'Clerk')

    result = summarize(earlier, middle, later)

    expect(result.paragraph).to include('“Clerk” in both 1910 and 1930 and “Teacher” in 1920')
    expect(result.sources).to eq([earlier, middle, later])
  end

  it 'connects residence, household, and schooling across censuses and cites the head records' do
    andrew = Data.define(:name).new('Andrew Aagaard')
    head_1940 = observation.new(year: 1940, name: 'Andrew Agaard', person_id: 42, person: andrew, relation_to_head: 'Head')
    head_1950 = observation.new(year: 1950, name: 'Andrew W Aagaard', person_id: 42, person: andrew, relation_to_head: 'Head')
    child = observation.new(year: 1940, age: 7, locality: caroline, locality_id: 1, family_id: '148',
                            street_name: 'Coddington', street_address: 'Coddington Rd',
                            relation_to_head: 'Daughter', fellows: [head_1940], attended_school: true, occupation: 'None')
    teenager = observation.new(year: 1950, locality: caroline, locality_id: 1, family_id: '152',
                               street_name: 'Coddington', street_address: '1784 Coddington Rd', street_house_number: '1784',
                               relation_to_head: 'Daughter', fellows: [head_1950], occupation: 'Student Senior in High School')

    result = summarize(teenager, child)

    expect(result.paragraph).to eq(
      'At seven, Frances Aagaard was recorded as attending school in 1940, and she was listed as a high school senior in 1950. ' \
      'She lived on Coddington Rd in Caroline, at number 1784 in 1950. ' \
      'She was listed as the daughter of Andrew Aagaard.'
    )
    expect(result.paragraph).not_to match(/moved|same house|employed/)
    expect(result.paragraph.scan('Andrew Aagaard').length).to eq(1)
    expect(result.sources).to eq([child, head_1940, teenager, head_1950])
    expect(summarize(child, teenager)).to eq(result)
  end

  it 'does not combine identically named household heads without a shared link' do
    first_head = observation.new(year: 1910, name: 'John Jones', relation_to_head: 'Head')
    later_head = observation.new(year: 1920, name: 'John Jones', relation_to_head: 'Head')
    first = observation.new(year: 1910, locality_id: 1, family_id: '12', relation_to_head: 'Daughter', fellows: [first_head])
    later = observation.new(year: 1920, locality_id: 1, family_id: '12', relation_to_head: 'Daughter', fellows: [later_head])

    result = summarize(first, later)

    expect(result.paragraph).to include('the daughter of John Jones in 1910 and the daughter of John Jones in 1920')
    expect(result.sources).to eq([first, first_head, later, later_head])
  end

  it 'describes dated work observations without inventing an employer or promotion' do
    earlier = observation.new(year: 1940, occupation: 'Laborer', industry: 'Gun Factory')
    later = observation.new(year: 1950, occupation: 'Hand Sander', industry: 'Gun Factory')

    result = summarize(earlier, later, name: 'Andrew Aagaard', sex: 'M')

    expect(result.paragraph).to eq(
      'Andrew Aagaard worked as “Laborer” in 1940 (industry “Gun Factory”) and “Hand Sander” in 1950 (industry “Gun Factory”).'
    )
    expect(summarize(earlier, later, residence(1960, '12 Main St'), sex: nil).paragraph).to include('They lived at 12 Main St')
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
