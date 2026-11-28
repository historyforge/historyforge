# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Building predecessor history' do
  let(:option_label) { '315 Hillview Pl (also recorded as 115 Mechanic St)' }
  let(:locality) { create(:locality) }
  let!(:predecessor) do
    create(:building, :reviewed, locality:, lat: 42.45, name: '315 Hillview Pl',
           addresses: [
             build(:address, prefix: nil, city: nil, is_primary: true, house_number: '315', name: 'Hillview', suffix: 'Pl', year: 1919),
             build(:address, prefix: nil, city: nil, is_primary: false, house_number: '115', name: 'Mechanic', suffix: 'St', year: 1900),
           ])
  end
  let!(:successor) do
    create(:building, :reviewed, locality:, name: '317 Hillview Pl', building_type_ids: [3], year_latest: nil,
           addresses: [build(:address, prefix: nil, city: nil, house_number: '317', name: 'Hillview', suffix: 'Pl', year: 1919)])
  end

  scenario 'an editor finds the predecessor under a historical address and a guest sees each dwelling', :js do
    nearby = create(:building, :reviewed, locality:,
                    addresses: [build(:address, prefix: nil, city: nil, house_number: '319', name: 'Hillview', suffix: 'Pl')])
    other_locality = create(:building, :reviewed,
                            addresses: [build(:address, prefix: nil, city: nil, house_number: '115', name: 'Mechanic', suffix: 'St')])
    mary1900 = census_record(1900, predecessor, address: historical_address)
    mary1910 = census_record(1910, predecessor, address: historical_address)
    mary1920 = census_record(1920, successor, address: { street_house_number: '317', street_name: 'Hillview', street_suffix: 'Pl' })

    sign_in create(:builder)
    visit edit_building_path(successor)
    expect(page).to have_select('Predecessor building', with_options: [nearby.primary_street_address.squish])
    expect(page).to have_no_select('Predecessor building', with_options: [successor.primary_street_address.squish])
    fill_in 'First year recorded separately', with: '1911'
    fill_in 'Search recorded addresses', with: '115 Mechanic St'
    option = find('[role=option]', exact_text: option_label)
    expect(page).to have_no_css('[role=option]', exact_text: other_locality.primary_street_address.squish)
    option.click
    expect(page).to have_select('Predecessor building', selected: option_label)
    within('.form-actions') { click_button 'Save', exact: true }
    expect(page).to have_content('Building updated.')
    expect(successor.reload).to have_attributes(parent_id: predecessor.id, hive_year: 1911)

    click_link 'Edit'
    expect(page).to have_select('Predecessor building', selected: option_label)
    expect(page).to have_field('First year recorded separately', with: '1911')

    using_session(:guest) do
      visit building_path(successor)
      expect(page).to have_content('First year recorded separately: 1911')
      expect(page).to have_content("317 Hillview Pl #{locality.name} (as of 1919)")
      expect_household(mary1900, '115 Mechanic St')
      expect_household(mary1910, '115 Mechanic St')
      expect_household(mary1920, '317 Hillview Pl')
    end
    expect([mary1900.reload.building_id, mary1910.reload.building_id, mary1920.reload.building_id])
      .to eq([predecessor.id, predecessor.id, successor.id])
  end

  scenario 'an unmapped building keeps the street-and-block suggestions' do
    successor.update!(lat: nil, lon: nil)
    sign_in create(:builder)

    visit edit_building_path(successor)
    expect(page).to have_select('Predecessor building', with_options: [option_label])
    expect(page).to have_no_select('Predecessor building', with_options: ['317 Hillview Pl'])
  end

  scenario 'the cutoff census comes from the successor and an addressless earlier household links to the predecessor' do
    successor.update!(parent: predecessor, hive_year: 1910)
    earlier = census_record(1900, predecessor)
    same_year_at_predecessor = census_record(1910, predecessor)
    same_year_at_successor = census_record(1910, successor, address: { street_house_number: '317', street_name: 'Mechanic', street_suffix: 'St' })

    visit building_path(successor)
    within(household(1900)) do
      expect(page).to have_link('315 Hillview Pl', href: building_path(predecessor))
      expect(page).to have_link('Mary A Collins', href: polymorphic_path(earlier))
    end
    expect_household(same_year_at_successor, '317 Mechanic St')
    expect(page).to have_no_link('Mary A Collins', href: polymorphic_path(same_year_at_predecessor))
  end

  scenario 'a guest sees only readable buildings, census years, and rows' do
    successor.update!(parent: predecessor, hive_year: 1911)
    earlier = census_record(1900, predecessor, address: historical_address)
    hidden_year = census_record(1910, predecessor, address: historical_address)
    later = census_record(1920, successor)
    unreviewed = census_record(1900, predecessor, reviewed_at: nil, first_name: 'Private')
    Setting.find_by!(key: 'enabled_public_1910').update!(value: '0')
    Setting.expire_cache

    visit building_path(successor)
    expect_household(earlier, '115 Mechanic St')
    expect(page).to have_no_link(href: polymorphic_path(hidden_year))
    expect(page).to have_no_link(href: polymorphic_path(unreviewed))

    predecessor.update!(reviewed_at: nil, lat: successor.lat, lon: successor.lon)
    visit building_path(successor)
    expect(page).to have_no_link(href: building_path(predecessor))
    expect(page).to have_no_content('115 Mechanic St')
    map = JSON.parse(find('#miniforge', visible: :all)['data-initial-state']).fetch('buildings')
    expect(map.fetch('buildings').pluck('id')).not_to include(predecessor.id)
    expect(map.fetch('current').fetch('object')).to include('parent_id' => nil, 'hive_year' => nil)
    expect(page).to have_no_link(href: polymorphic_path(earlier))
    expect_household(later, nil)
  end

  def historical_address
    { street_house_number: '115', street_name: 'Mechanic', street_suffix: 'St' }
  end

  def census_record(year, building, address: {}, reviewed_at: Time.current, first_name: 'Mary')
    create(:"census#{year}_record", building:, locality:, first_name:, middle_name: 'A.', last_name: 'Collins',
           sex: 'F', reviewed_at:, **address)
  end

  def household(year)
    find('.card', text: "Resident Household in #{year}")
  end

  def expect_household(record, address)
    within(household(record.year)) do
      expect(find('.card-header')).to have_text(address) if address
      expect(page).to have_link('Mary A Collins', href: polymorphic_path(record))
    end
  end
end
