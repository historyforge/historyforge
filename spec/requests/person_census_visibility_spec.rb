# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Census record visibility on Person pages', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:person) { create(:person) }
  let(:locality) { create(:locality) }
  let!(:public_record) { census_record(1910, person, reviewed: true) }
  let!(:unreviewed_record) { census_record(1920, person, reviewed: false) }
  let!(:private_record) { census_record(1930, person, reviewed: true) }
  let!(:public_relative) { census_record(1910, create(:person), reviewed: true) }
  let!(:unreviewed_relative) { census_record(1910, create(:person), reviewed: false) }
  let!(:relative_of_unreviewed_record) { census_record(1920, create(:person), reviewed: true) }
  let!(:private_relative) { census_record(1930, create(:person), reviewed: true) }

  before do
    allow(Setting).to receive(:can_view_public?).and_call_original
    allow(Setting).to receive(:can_view_public?).with(1910).and_return(true)
    allow(Setting).to receive(:can_view_public?).with(1920).and_return(true)
    allow(Setting).to receive(:can_view_public?).with(1930).and_return(false)
    allow(Setting).to receive(:can_view_private?).and_call_original
    allow(Setting).to receive(:can_view_private?).with(1930).and_return(true)
  end

  def census_record(year, linked_person, reviewed:)
    relation_to_head = linked_person == person ? 'Head' : 'Boarder'
    create(:"census#{year}_record", locality:, relation_to_head:).tap do |record|
      record.update_columns(person_id: linked_person.id, reviewed_at: reviewed ? Time.current : nil)
    end
  end

  def expect_visibility(records:, relatives:)
    get person_path(person)
    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    entries = page.css('.person-census-entry')
    expect(entries.map { |entry| entry.at_css('time')['datetime'] }).to eq(records.map { |record| record.year.to_s })
    expect(entries.map { |entry| entry.at_css('a:contains("View census record")')['href'] })
      .to eq(records.map { |record| polymorphic_path(record) })
    entries.zip(records).each do |entry, record|
      expected_household = relatives.select { |relative| relative.year == record.year }
      expect(entry.css('details a').map { |link| link['href'] })
        .to match_array(expected_household.map { |relative| person_path(relative.person_id) })
    end
    comparison = page.at_css('.person-census table')
    if records.many?
      expect(comparison.css('tbody a').map { |link| link['href'] })
        .to eq(records.map { |record| polymorphic_path(record) })
    else
      expect(comparison).to be_nil
    end

    [public_record, unreviewed_record, private_record].each do |record|
      get polymorphic_path(record)
      if records.include?(record)
        expect(response).to have_http_status(:ok)
      else
        expect(response).to redirect_to(root_path)
      end
    end
  end

  it 'shows guests only reviewed records from public years' do
    expect_visibility(records: [public_record], relatives: [public_relative])
  end

  it 'shows reviewed attachments alongside visible census evidence' do
    author = create(:active_user)
    narrative = Narrative.create!(created_by: author, people: [person], story: 'A family history',
                                  sources: 'City directory')
    video = Video.create!(created_by: author, people: [person], caption: 'An interview')

    get person_path(person)
    expect(response.body).not_to include('A family history', 'An interview')

    narrative.update!(reviewed_at: Time.current)
    get person_path(person)
    page = Nokogiri::HTML(response.body)
    expect(page.at_css('.person-census .person-census-entry')).to be_present
    expect(page.at_css('.person-associated-content').text).to include('A family history')
    expect(page.at_css('.person-associated-content').text).not_to include('An interview')

    narrative.update!(reviewed_at: nil)
    video.update!(reviewed_at: Time.current)
    get person_path(person)
    page = Nokogiri::HTML(response.body)
    expect(page.at_css('.person-census .person-census-entry')).to be_present
    expect(page.at_css('.person-associated-content').text).to include('An interview')
    expect(page.at_css('.person-associated-content').text).not_to include('A family history')
  end

  it 'shows signed-in readers reviewed records from public and private years' do
    sign_in create(:active_user)

    expect_visibility(records: [public_record, private_record], relatives: [public_relative, private_relative])
  end

  it 'includes unreviewed records and their relatives for users who can read them' do
    sign_in create(:census_taker)

    expect_visibility(
      records: [public_record, unreviewed_record, private_record],
      relatives: [public_relative, unreviewed_relative, relative_of_unreviewed_record, private_relative]
    )
  end
end
