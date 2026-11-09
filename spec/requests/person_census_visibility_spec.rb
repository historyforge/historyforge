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
    create(:"census#{year}_record", locality:).tap do |record|
      record.update_columns(person_id: linked_person.id, reviewed_at: reviewed ? Time.current : nil)
    end
  end

  def expect_visibility(records:, relatives:)
    get person_path(person)
    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    cards = page.css('.card').select { |card| card.at_css('.card-header') }
    census_card = cards.find { |card| card.at_css('.card-header').text.strip == 'Census Records' }
    relative_cards = cards.select { |card| card.at_css('.card-header').text.strip.start_with?('Relatives in ') }

    expect(census_card.css('tbody a').map { |link| link['href'] })
      .to eq(records.map { |record| polymorphic_path(record) })
    expect(relative_cards.flat_map { |card| card.css('tbody a').map { |link| link['href'] } })
      .to eq(relatives.map { |record| person_path(record.person_id) })
    expect(relative_cards.map { |card| card.at_css('.card-header').text.strip })
      .to eq(relatives.map { |record| "Relatives in #{record.year} US Census" }.uniq)

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
