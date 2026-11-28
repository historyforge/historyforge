# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'people' do
  scenario 'saves a blank race and edits a race write-in on the Person record', :js do
    sign_in create(:administrator)
    person = create(:person, race: nil)
    census_record = create(:census1950_record, person:, race: 'iraq', sex: person.sex,
                           first_name: person.first_name, last_name: person.last_name,
                           locality: create(:locality), page_number: 1, line_number: 1, enum_dist: '1',
                           family_id: '1', relation_to_head: 'Head')
    save_person = "form[action='#{person_path(person)}'] input[type='submit'][value='Save']"
    write_in = 'input[aria-label="Other race as recorded"]:enabled'

    visit edit_person_path(person)
    expect(page).to have_checked_field('Left blank', name: 'person[race]')
    find(save_person).click
    expect(page).to have_current_path(person_path(person))
    expect(person.reload.race).to be_nil

    visit edit_person_path(person)
    choose 'person_race_other'
    find(write_in).set('Iraq "as recorded"')
    find(save_person).click
    expect(page).to have_current_path(person_path(person))
    expect(person.reload.race).to eq('Iraq "as recorded"')
    expect(census_record.reload.race).to eq('iraq')

    visit edit_person_path(person)
    expect(find(write_in).value).to eq('Iraq "as recorded"')
    find(write_in).set('Iraq')
    find(save_person).click
    expect(page).to have_current_path(person_path(person))
    expect(person.reload.race).to eq('Iraq')
  end

  scenario 'adds, edits, cancels and removes filters in the People grid', :js do
    sign_in create(:administrator)
    creator = create(:active_user, login: 'canal_reviewer')
    create(:person, first_name: 'Edward', last_name: 'Brown', sex: 'M')
    create(:person, first_name: 'William', last_name: 'Brown', sex: 'M', created_by_id: creator.id)
    create(:person, first_name: 'Mary', last_name: 'Brown', sex: 'F')
    create(:person, first_name: 'Joseph', last_name: 'Jones', sex: 'M')

    visit people_path
    click_button 'Add/edit filters'
    expect(page).to have_no_button('Add another condition')
    expect(page).to have_no_css('[data-remove-condition]')
    find('select.attribute option[value="name"]').select_option
    expect(page).to have_css('[data-remove-condition]')
    click_button 'Cancel'
    click_button 'Add/edit filters'
    expect(find('select.attribute').value).to eq('')
    find('select.attribute option[value="name"]').select_option
    find('select.scope option[value="name_cont"]').select_option
    find('input[name="s[name_cont]"]').set('Brown')
    click_button 'Add another condition'
    within(all('[data-filter-condition]').last) do
      expect(page).to have_no_css('[data-remove-condition]')
      find('select.attribute option[value="sex"]').select_option
      check 'Male'
    end
    click_button 'Add another condition'
    within(all('[data-filter-condition]').last) { select 'Creation details' }
    lookup = find('#creator_lookup')
    lookup.set('canal')
    expect(page).to have_css('[role="option"]', text: creator.login)
    lookup.send_keys(:arrow_down, :enter)
    expect(page).to have_field('s[creator_id]', type: :hidden, with: creator.id.to_s)
    lookup.set('unselected')
    expect(page).to have_field('s[creator_id]', type: :hidden, with: '')
    lookup.set('canal')
    find('[role="option"]', text: creator.login).click
    select 'Last 7 days', from: 'Creation date'
    expect(page).to have_no_css('#attribute-filters .attribute-filter')
    click_button 'Apply filters'

    within('#attribute-filters') do
      expect(page).to have_css('.attribute-filter', text: 'Brown')
      expect(page).to have_css('.attribute-filter', text: 'Male')
    end
    expect(page).to have_link('Brown, William')
    expect(page).to have_no_link('Brown, Mary')
    expect(page).to have_no_link('Jones, Joseph')
    expect(page).to have_no_link('Brown, Edward')
    expect(page).to have_no_css('.modal-backdrop')

    click_button "Created by #{creator.login}"
    expect(page).to have_field('creator_lookup', with: creator.login)
    select 'Today', from: 'Creation date'
    click_button 'Cancel'
    expect(page).to have_no_css('.modal.show')

    click_button 'Created in the last 7 days'
    expect(page).to have_select('Creation date', selected: 'Last 7 days')
    select 'Last 30 days', from: 'Creation date'
    click_button 'Apply filters'
    expect(page).to have_button('Created in the last 30 days')
    expect(page).to have_button("Created by #{creator.login}")

    find('button[aria-label="Remove Created by filter"]').click
    expect(page).to have_no_button("Created by #{creator.login}")
    expect(page).to have_button('Created in the last 30 days')
    expect(page).to have_no_css('.modal.show')
    expect(page).to have_link('Brown, Edward')
    expect(page).to have_link('Brown, William')
    expect(page).to have_no_link('Brown, Mary')
    expect(page).to have_no_link('Jones, Joseph')
    filters = Rack::Utils.parse_nested_query(URI.parse(page.current_url).query).fetch('s')
    expect(filters).to eq('creation_date_range' => 'last30', 'name_cont' => 'Brown', 'sex_in' => ['M'])
  end

  scenario 'renders one People grid when reconnecting to copied grid markup', :js do
    create(:person, first_name: 'William', last_name: 'Brown')
    visit people_path
    expect(page).to have_link('Brown, William')

    page.execute_script(<<~JS)
      const grid = document.querySelector('#grid')
      const copy = grid.cloneNode(true)
      copy.querySelector('.ag-root-wrapper').dataset.copiedGrid = 'true'
      grid.replaceWith(copy)
    JS

    expect(page).to have_css('#grid .ag-root-wrapper:not([data-copied-grid])')
    expect(page).to have_css('#grid .ag-root-wrapper', count: 1)
    expect(page).to have_link('Brown, William', count: 1)
  end

  scenario 'person editors can keep the census matching tables open across person pages', :js do
    editor = create(:active_user)
    editor.add_role Role.find_by(name: 'person record editor')
    sign_in editor

    locality = create(:locality)
    person = create(:person)
    relative = create(:person)
    record = create(:census1910_record, person:, locality:, relation_to_head: 'Head', reviewed_at: Time.current)
    relative_record = create(:census1910_record, person: relative, locality:, relation_to_head: 'Son',
                                               age: 12, pob: 'New York', reviewed_at: Time.current)
    create(:census1910_record, person: create(:person), locality:, relation_to_head: 'Son',
                              occupation: 'Private occupation')

    visit person_path(person)
    click_button 'Matching tables'

    within('#person-census-table') do
      expect(page).to have_link(href: polymorphic_path(record))
      expect(page).to have_text('Linked household members in the 1910 census')
      expect(page).to have_text('New York')
      expect(page).to have_no_text('Private occupation')
      find_link(relative_record.decorate.name, href: person_path(relative)).click
    end

    expect(page).to have_current_path(person_path(relative))
    expect(page).to have_css('#person-census-table')
    click_button 'Cards'
    expect(page).to have_css('#person-census-cards')
    expect(page).to have_no_css('#person-census-table')
  end

  scenario 'shows a matched variant as a link and the primary name in See', :js do
    person = create(:person, first_name: 'William', last_name: 'Brown')
    person.names.create!(first_name: 'William', last_name: 'Browne')

    visit people_path(s: { names_last_name_eq: 'Browne' })

    expect(page).to have_css('.ag-header-cell[col-id="see_name"]', text: 'See')
    expect(page).to have_link('Browne, William', href: /#{Regexp.escape(person_path(person))}/)
    expect(page).to have_css('.ag-cell[col-id="see_name"]', text: 'Brown, William')
    expect(page).to have_no_link('Brown, William')

    visit people_path(s: { names_last_name_eq: 'Brown' })

    expect(page).to have_link('Brown, William')
    expect(page).to have_no_css('.ag-header-cell[col-id="see_name"]')
  end

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
    person = create(:person, birth_year: 1933, pob: 'Burma', is_pob_estimated: false, race: 'Burmese')

    visit person_path(person)

    expect(page).to have_no_css('section[aria-label="Biography"]')
    data = JSON.parse(find('script[type="application/ld+json"]', visible: :all).native.content)
    expect(data).not_to have_key('alternateName')
    within('table[aria-label="Person details"]') do
      expect(page).to have_css('th', text: 'Born')
      expect(page).to have_css('td', text: 'About 1933')
      expect(page).to have_css('td', text: 'Burma')
      expect(page).to have_css('td', text: 'Other-Burmese')
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

  scenario 'the new person form defaults to an exact death year', driver: :rack_test do
    sign_in create(:administrator)

    visit new_person_path

    expect(page).to have_unchecked_field('person_is_death_year_estimated')
  end

  scenario 'entering a death year on an older person record defaults to exact', driver: :rack_test do
    sign_in create(:administrator)
    person = create(:person, death_year: nil, is_death_year_estimated: true)

    visit edit_person_path(person)
    expect(page).to have_unchecked_field('person_is_death_year_estimated')
    fill_in 'Death Year', with: '1940'
    within('form.edit_person') { click_on 'Save' }

    expect(person.reload).to have_attributes(death_year: 1940, is_death_year_estimated: false)
    within('table[aria-label="Person details"]') do
      expect(page).to have_css('tr', text: /Died\s*1940/)
    end
  end

  scenario 'an explicitly estimated death year stays estimated when editing a person', driver: :rack_test do
    sign_in create(:administrator)
    person = create(:person, death_year: 1940, is_death_year_estimated: true)

    visit edit_person_path(person)
    expect(page).to have_checked_field('person_is_death_year_estimated')
    within('form.edit_person') { click_on 'Save' }

    expect(person.reload.is_death_year_estimated).to be true
    within('table[aria-label="Person details"]') do
      expect(page).to have_css('tr', text: /Died\s*About 1940/)
    end
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
