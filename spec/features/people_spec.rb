# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'people' do
  scenario 'the census narrative uses the viewer’s census permissions', driver: :rack_test do
    allow(People::PublicUrlOptions).to receive(:call).and_return({})
    person = create(:person, birth_year: 1880, is_birth_year_estimated: false,
                             death_year: 1940, is_death_year_estimated: false)
    unreviewed_record = create(:census1920_record, person:, age: 50, occupation: 'Carpenter')
    public_record = create(:census1910_record, person:, age: 30, pob: 'New York', street_name: 'Coddington',
                           street_suffix: 'Rd', reviewed_at: Time.current)
    hidden_record = create(:census1930_record, person:, age: 60, occupation: 'Banker', reviewed_at: Time.current)
    allow(Setting).to receive(:can_view_public?).and_call_original
    allow(Setting).to receive(:can_view_public?).with(1930).and_return(false)

    visit person_path(person, ref: 'search')

    expect(page).to have_no_text('Census Summary')
    expect(page).to have_no_css('h2', text: /\A(?:About|Person details)\z/i)
    within('.content-header .pills') do
      expect(page).to have_link('View All', href: people_path)
    end
    expect(page).to have_no_css('.person-actions')
    expect(page).to have_css('.col-lg-4 .card table[aria-label="Person details"]')
    within('section[aria-label="Biography"]') do
      expect(page).to have_text('lived on Coddington Rd')
      expect(page).to have_link('1910 census', href: /#{Regexp.escape(polymorphic_path(public_record))}\z/)
      expect(page).to have_no_link(href: /#{Regexp.escape(polymorphic_path(unreviewed_record))}\z/)
      expect(page).to have_no_link(href: /#{Regexp.escape(polymorphic_path(hidden_record))}\z/)
      expect(page).to have_no_text(/Carpenter|Banker/)
    end

    data = JSON.parse(find('script[type="application/ld+json"]', visible: :all).native.content)
    origin = URI(page.current_url).origin
    canonical_url = "#{origin}#{person_path(person)}"
    source_url = "#{origin}#{polymorphic_path(public_record)}"

    expect(data).to include(
      '@context' => 'https://schema.org',
      '@type' => 'Person',
      '@id' => "#{canonical_url}#person",
      'url' => canonical_url,
      'mainEntityOfPage' => canonical_url,
      'identifier' => person.id.to_s,
      'name' => person.name,
      'birthDate' => '1880',
      'deathDate' => '1940',
    )
    expect(data['description']).to include('lived on Coddington Rd')
    expect(data['subjectOf']).to eq([
      { '@type' => 'CreativeWork', '@id' => "#{source_url}#census-record",
        'url' => source_url, 'name' => '1910 census record' },
    ])

    sign_in create(:administrator)
    visit person_path(person)

    expect(page).to have_no_css('script[type="application/ld+json"]', visible: :all)

    within('section[aria-label="Biography"]') do
      expect(page).to have_link('1910 census')
      expect(page).to have_link('1930 census', href: /#{Regexp.escape(polymorphic_path(hidden_record))}\z/)
      expect(page).to have_text('Banker')
    end

    allow(Setting).to receive(:can_view_private?).and_call_original
    allow(Setting).to receive(:can_view_private?).with(1930).and_return(false)
    visit person_path(person)

    within('section[aria-label="Biography"]') do
      expect(page).to have_no_text('Banker')
      expect(page).to have_link('1920 census', href: /#{Regexp.escape(polymorphic_path(unreviewed_record))}\z/)
      expect(page).to have_text('Carpenter')
    end
  end

  scenario 'keeps the facts visible without generating an About paragraph for sparse records', driver: :rack_test do
    person = create(:person, birth_year: 1933)

    visit person_path(person)

    expect(page).to have_no_css('section[aria-label="Biography"]')
    data = JSON.parse(find('script[type="application/ld+json"]', visible: :all).native.content)
    expect(data).not_to have_key('alternateName')
    within('table[aria-label="Person details"]') do
      expect(page).to have_css('th', text: 'Born')
      expect(page).to have_css('td', text: 'About 1933')
    end
  end

  scenario 'Person JSON-LD escapes script delimiters and omits unsupported facts', driver: :rack_test do
    person = create(:person, birth_year: 1880, is_birth_year_estimated: true, death_year: nil)
    person.update_columns(first_name: %q(Mary "</script><script id="injected-person-jsonld">alert(1)</script>&))

    visit person_path(person)

    json = find('script[type="application/ld+json"]', visible: :all).native.content
    data = JSON.parse(json)

    expect(json).not_to include('</script>', '<script', '&')
    expect(page).to have_no_css('script#injected-person-jsonld', visible: :all)
    expect(data['name']).to eq(person.name)
    expect(data.keys).not_to include('description', 'birthDate', 'deathDate', 'subjectOf')
  end

  scenario 'Person JSON-LD uses the visible name variants and falls back to the public description', driver: :rack_test do
    person = create(:person, description: '<p>A local <em>historian</em>.</p>')
    person.names.create!(first_name: 'Mary', last_name: 'Jones')
    person.names.create!(first_name: 'Maria', last_name: 'Jones')

    visit person_path(person)

    data = JSON.parse(find('script[type="application/ld+json"]', visible: :all).native.content)
    expect(data['description']).to eq('A local historian.')
    expect(data['alternateName']).to contain_exactly('Mary Jones', 'Maria Jones')
    expect(page).to have_css('tr', text: /Also recorded as.*Maria Jones, Mary Jones/)
  end

  scenario 'edit people' do
    sign_in create(:administrator)
    person = create(:person, death_year: 1940, is_death_year_estimated: false)
    visit person_path(person.id)
    expect(page).to have_content person.name
    expect(page).to have_content '1940'
    expect(page).to have_no_css('.content-header .pills', text: 'View All')
    within('.person-actions') do
      expect(page).to have_link('View All', href: people_path)
      click_on 'Edit'
    end
    fill_in 'Birth Year', with: '1850'
    find(:checkbox, 'person_is_birth_year_estimated', checked: true)
    find(:checkbox, 'person_is_death_year_estimated', checked: false)
    fill_in 'Place of Birth', with: 'New Orleans'
    find(:checkbox, 'person_is_pob_estimated', checked: true)
    click_on 'Save', match: :first
    expect(page).to have_content '1850'
  end
end
