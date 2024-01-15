# frozen_string_literal: true

require 'rails_helper'

RSpec.describe People::GenerateFromCensusRecord do
  let(:person) { described_class.run!(record:) }
  let(:record) { create(:census1900_record, birth_year: 1872, age: 28) }

  it { expect(person.race).to eq(record.race) }
  it { expect(person.sex).to eq(record.sex) }
  it { expect(person.first_name).to eq(record.first_name) }
  it { expect(person.middle_name).to eq(record.middle_name) }
  it { expect(person.last_name).to eq(record.last_name) }
  it { expect(person.id).to(eq(record.person_id)) }
end
