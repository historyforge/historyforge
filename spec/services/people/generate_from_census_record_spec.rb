# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::GenerateFromCensusRecord do
  let(:record) { create(:census1900_record, birth_year: 1872, age: 28) }
  subject { described_class.new(record).perform }
  it 'works' do
    expect(subject.race).to eq(record.race)
    expect(subject.sex).to eq(record.sex)
    expect(subject.first_name).to eq(record.first_name)
    expect(subject.middle_name).to eq(record.middle_name)
    expect(subject.last_name).to eq(record.last_name)
    expect(record.person_id).to eq(subject.id)
  end
end
