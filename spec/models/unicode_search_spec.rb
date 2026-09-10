# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Unicode search', type: :model do
  it 'finds a person using an uppercase accented name' do
    person = create(:person, first_name: 'Élodie', last_name: 'García')
    create(:person, first_name: 'Alice', last_name: 'Smith')

    expect(Person.ransack(name_cont: 'ÉLODIE').result).to contain_exactly(person)
  end

  it 'finds addresses and buildings using an uppercase accented street name' do
    building = create(:building, addresses: [build(:address, name: 'Érables', is_primary: true)])
    create(:building)

    expect(Address.ransack(street_address_cont: 'ÉRABLES').result).to contain_exactly(building.addresses.first)
    expect(Building.joins(:addresses).ransack(street_address_cont: 'ÉRABLES').result).to contain_exactly(building)
  end
end
