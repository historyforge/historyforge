# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'people' do
  scenario 'a public census summary links only to readable census records', driver: :rack_test do
    allow(People::PublicUrlOptions).to receive(:call).and_return({})
    person = create(:person, birth_year: 1880, is_birth_year_estimated: false,
                             death_year: 1940, is_death_year_estimated: false)
    unreviewed_record = create(:census1920_record, person:, age: 50, pob: 'Pennsylvania')
    public_record = create(:census1910_record, person:, age: 30, pob: 'New York', reviewed_at: Time.current)
    hidden_record = create(:census1930_record, person:, age: 60, pob: 'Pennsylvania', reviewed_at: Time.current)
    allow(Setting).to receive(:can_view_public?).and_call_original
    allow(Setting).to receive(:can_view_public?).with(1930).and_return(false)

    visit person_path(person, ref: 'search')

    within('section[aria-labelledby="census-summary-heading"]') do
      expect(page).to have_text('The recorded age suggests a birth year around 1880.')
      expect(page).to have_link('1910 census', href: /#{Regexp.escape(polymorphic_path(public_record))}\z/)
      expect(page).to have_no_link(href: /#{Regexp.escape(polymorphic_path(unreviewed_record))}\z/)
      expect(page).to have_no_link(href: /#{Regexp.escape(polymorphic_path(hidden_record))}\z/)
      expect(page).to have_no_text('Pennsylvania')
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
      'identifier' => person.id.to_s,
      'name' => person.name,
      'birthDate' => '1880',
      'deathDate' => '1940',
    )
    expect(data['description']).to include('The recorded age suggests a birth year around 1880.')
    expect(data['subjectOf']).to eq([
      { '@type' => 'CreativeWork', '@id' => "#{source_url}#census-record",
        'url' => source_url, 'name' => '1910 census record' },
    ])
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

  scenario 'Person JSON-LD uses the public description when there is no census summary', driver: :rack_test do
    person = create(:person, description: '<p>A local <em>historian</em>.</p>')

    visit person_path(person)

    data = JSON.parse(find('script[type="application/ld+json"]', visible: :all).native.content)
    expect(data['description']).to eq('A local historian.')
  end

  scenario 'edit people' do
    sign_in create(:administrator)
    person = create(:person, death_year: 1940, is_death_year_estimated: false)
    visit person_path(person.id)
    expect(page).to have_content person.name
    expect(page).to have_content '1940'
    click_on 'Edit'
    fill_in 'Birth Year', with: '1850'
    find(:checkbox, 'person_is_birth_year_estimated', checked: true)
    find(:checkbox, 'person_is_death_year_estimated', checked: false)
    fill_in 'Place of Birth', with: 'New Orleans'
    find(:checkbox, 'person_is_pob_estimated', checked: true)
    click_on 'Save', match: :first
    expect(page).to have_content '1850'
  end
end
