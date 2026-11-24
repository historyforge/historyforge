# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating a person from a census record', type: :request do
  include Devise::Test::IntegrationHelpers

  %i[race sex].each do |field|
    it "reports a missing #{field} and leaves the census record unlinked" do
      sign_in create(:administrator)
      record = create(:census1880_record, locality: create(:locality), first_name: 'Beatrice', last_name: 'Brown',
                                         family_id: '1', page_number: 1, page_side: 'A', line_number: 1,
                                         relation_to_head: 'Head', sex: 'F', race: 'W', enum_dist: '1')
      record.update_column(field, nil)
      path = census_record_path(year: 1880, id: record.id)
      action = "#{path}/make_person"

      get path
      form = Nokogiri::HTML(response.body).at_css("form[action='#{action}'][method='post']")
      expect(form.at_css('input[name="_method"]')['value']).to eq('put')

      expect do
        post action, params: { _method: 'put' }, headers: { 'Referer' => path }
      end.not_to change(Person, :count)

      expect(response).to redirect_to(path)
      expect(flash[:error]).to include("#{field.to_s.humanize} can't be blank")
      expect(record.reload.person_id).to be_nil
    end
  end
end
