# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Building address details', type: :request do
  include Devise::Test::IntegrationHelpers

  it 'shows the building Locality and keeps the as-of year on dated addresses' do
    locality = create(:locality, name: 'Town of Ithaca')
    primary = build(:address, house_number: '371', prefix: nil, name: 'Arboretum', suffix: 'Rd', city: 'Ithaca', year: 1953)
    historical = build(:address, is_primary: false, house_number: '2', prefix: nil, name: 'Forest Home',
                                 suffix: 'Dr', city: nil)
    building = create(:building, :reviewed, locality:, addresses: [primary, historical])

    get building_path(building)

    expect(response).to have_http_status(:ok)
    address = Nokogiri::HTML(response.body).at_xpath('//dt[normalize-space(.)="Address"]/following-sibling::dd[1]')
    expect(address.children.select(&:text?).map(&:text)).to contain_exactly(
      '371 Arboretum Rd Town of Ithaca (as of 1953)', '2 Forest Home Dr Town of Ithaca'
    )
  end

  it 'allows an editor to clear Place on the primary address without changing Locality' do
    sign_in create(:administrator)
    locality = create(:locality, name: 'Town of Ithaca')
    building = create(:building, locality:)
    address = building.address

    patch building_path(building), params: {
      building: { addresses_attributes: [{ id: address.id, name: address.name, city: '' }] }
    }

    expect(response).to redirect_to(building_path(building))
    expect(address.reload.city).to be_nil
    expect(building.reload.locality).to eq(locality)
  end
end
