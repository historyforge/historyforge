# frozen_string_literal: true

require 'active_support/all'
require_relative '../../../app/services/people/census_summary'

RSpec.describe People::CensusSummary do
  let(:observation) { Data.define(:year, :id, :age, :pob) }

  it 'attributes the estimated birth year and recorded birthplace to one census' do
    record = observation.new(year: 1910, id: 1, age: 30, pob: 'New York')

    summary = described_class.call(records: [record])

    expect(summary.paragraph).to eq('This person is listed in the 1910 census. ' \
                                    'The recorded age suggests a birth year around 1880. ' \
                                    'The recorded birthplace is New York.')
    expect(summary.sources).to eq([record])
  end

  it 'sorts sources and allows a one-year difference in birth estimates' do
    earlier = observation.new(year: 1900, id: 2, age: 20, pob: 'New York')
    later = observation.new(year: 1910, id: 1, age: 29, pob: 'new york')

    summary = described_class.call(records: [later, earlier])

    expect(summary.paragraph).to eq('This person is listed in the 1900 and 1910 censuses. ' \
                                    'The recorded ages suggest a birth year around 1880. ' \
                                    'The recorded birthplace is New York.')
    expect(summary.sources).to eq([earlier, later])
    expect(described_class.call(records: [earlier, later])).to eq(summary)
  end

  it 'reports disagreement without picking a birth year or birthplace' do
    earlier = observation.new(year: 1900, id: 1, age: 20, pob: 'New York')
    later = observation.new(year: 1910, id: 1, age: 22, pob: 'Pennsylvania')

    summary = described_class.call(records: [earlier, later])

    expect(summary.paragraph).to eq('This person is listed in the 1900 and 1910 censuses. ' \
                                    'The recorded ages suggest conflicting birth years. ' \
                                    'The census records list different birthplaces.')
    expect(summary.sources).to eq([earlier, later])
  end

  it 'omits birth details when the records have missing values or transcription markers' do
    earlier = observation.new(year: 1900, id: 1, age: nil, pob: ' ')
    later = observation.new(year: 1910, id: 2, age: 999, pob: 'Illegible')
    latest = observation.new(year: 1950, id: 3, age: -1, pob: 'Unknown')

    summary = described_class.call(records: [earlier, later, latest])

    expect(summary.paragraph).to eq('This person is listed in the 1900, 1910, and 1950 censuses.')
    expect(summary.sources).to eq([earlier, later, latest])
  end

  it 'returns no summary when there are no sources' do
    expect(described_class.call(records: [])).to be_nil
  end
end
