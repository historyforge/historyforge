# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Invalid form submissions', type: :request do
  let(:user) { create(:administrator) }

  before do
    post user_session_path, params: { user: { email: user.email, password: 'b1g_sekrit' } }
  end

  ['text/html', 'text/vnd.turbo-stream.html, text/html'].each do |accept|
    context "accepting #{accept}" do
      let(:headers) { { 'ACCEPT' => accept } }

      it 'renders an invalid census edit with input intact and no saved changes' do
        record = create(:census1910_record, notes: 'Original notes')
        original = record.attributes
        patch census1910_record_path(record), params: {
          census_record: { first_name: '', notes: 'Keep this draft' }
        }, headers: headers

        expect(response).to have_http_status(422)
        document = Nokogiri::HTML(response.body)
        expect(document.text).to include("can't be blank")
        expect(document.at_css('textarea[name="census_record[notes]"]').text.delete_prefix("\n")).to eq('Keep this draft')
        expect(record.reload.attributes).to eq(original)
      end

      it 'does not partially save a building or its nested address on an invalid edit' do
        building = create(:building, notes: 'Original notes')
        address = building.addresses.first
        original_building = building.attributes
        original_address = address.attributes
        long_name = 'A' * 256
        patch building_path(building), params: {
          building: { name: long_name, notes: 'Keep this draft',
                      addresses_attributes: { '0' => { id: address.id, house_number: '987' } } }
        }, headers: headers

        expect(response).to have_http_status(422)
        document = Nokogiri::HTML(response.body)
        expect(document.text).to include('is too long')
        expect(document.at_css('input[name="building[name]"]')['value']).to eq(long_name)
        expect(document.at_css('textarea[name="building[notes]"]').text.delete_prefix("\n")).to eq('Keep this draft')
        expect(building.reload.attributes).to eq(original_building)
        expect(address.reload.attributes).to eq(original_address)
      end

      it 'retains narrative text when citations are missing without saving rich text rows' do
        original_counts = [Narrative.count, ActionText::RichText.count]
        post narratives_path, params: {
          narrative: { story: '<p>Keep this warehouse story</p>', sources: '', notes: 'Draft notes' }
        }, headers: headers

        expect(response).to have_http_status(422)
        document = Nokogiri::HTML(response.body)
        expect(document.text).to include("can't be blank")
        expect(document.at_css('input[name="narrative[story]"]')['value']).to include('Keep this warehouse story')
        expect(document.at_css('textarea[name="narrative[notes]"]').text.delete_prefix("\n")).to eq('Draft notes')
        expect([Narrative.count, ActionText::RichText.count]).to eq(original_counts)
      end

      it 'rejects a photograph without an upload and retains its caption' do
        expect do
          post photographs_path, params: { photograph: { caption: 'Warehouse draft' } }, headers: headers
        end.not_to change(Photograph, :count)

        expect(response).to have_http_status(422)
        document = Nokogiri::HTML(response.body)
        expect(document.css('.error_messages li').map(&:text)).to include("File can't be blank")
        expect(document.at_css('textarea[name="photograph[caption]"]').text.delete_prefix("\n")).to eq('Warehouse draft')
      end
    end
  end
end
