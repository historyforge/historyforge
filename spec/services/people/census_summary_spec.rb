# frozen_string_literal: true

require 'active_support/all'
require_relative '../../../app/services/people/census_summary'

RSpec.describe People::CensusSummary do
  it 'attributes the estimated birth year and recorded birthplace to one census' do
    record = { year: 1910, id: 1, age: 30, pob: 'New York' }

    summary = described_class.call(observations: [record])

    expect(summary).to eq('This person is listed in the 1910 census. ' \
                          'The recorded age suggests a birth year around 1880. ' \
                          'The recorded birthplace is New York.')
  end

  it 'sorts observations and allows a one-year difference in birth estimates' do
    earlier = { year: 1900, id: 2, age: 20, pob: 'New York' }
    later = { year: 1910, id: 1, age: 29, pob: 'new york' }

    summary = described_class.call(observations: [later, earlier])

    expect(summary).to eq('This person is listed in the 1900 and 1910 censuses. ' \
                          'The recorded ages suggest a birth year around 1880. ' \
                          'The recorded birthplace is New York.')
    expect(described_class.call(observations: [earlier, later])).to eq(summary)
  end

  it 'reports disagreement without picking a birth year or birthplace' do
    earlier = { year: 1900, id: 1, age: 20, pob: 'New York' }
    later = { year: 1910, id: 1, age: 22, pob: 'Pennsylvania' }

    summary = described_class.call(observations: [earlier, later])

    expect(summary).to eq('This person is listed in the 1900 and 1910 censuses. ' \
                          'The recorded ages suggest conflicting birth years. ' \
                          'The census records list different birthplaces.')
  end

  it 'omits birth details when the records have missing values or transcription markers' do
    earlier = { year: 1900, id: 1, age: nil, pob: ' ' }
    later = { year: 1910, id: 2, age: 999, pob: 'Illegible' }
    latest = { year: 1950, id: 3, age: -1, pob: 'Unknown' }

    summary = described_class.call(observations: [earlier, later, latest])

    expect(summary).to eq('This person is listed in the 1900, 1910, and 1950 censuses.')
  end

  it 'returns no summary when there are no sources' do
    expect(described_class.call(observations: [])).to be_nil
  end
end
