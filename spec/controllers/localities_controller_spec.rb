# frozen_string_literal: true

# == Schema Information
#
# Table name: localities
#
#  id                   :bigint           not null, primary key
#  name                 :string
#  latitude             :decimal(, )
#  longitude            :decimal(, )
#  position             :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  year_street_renumber :integer
#  slug                 :string
#  short_name           :string
#  primary              :boolean          default(FALSE), not null
#
# Indexes
#
#  index_localities_on_slug  (slug) UNIQUE
#
require 'rails_helper'

RSpec.describe LocalitiesController do
  let(:locality) { create(:locality) }

  describe '#set' do
    it 'sets the locality in the session' do
      put :set, params: { id: locality.id }
      expect(response).to have_http_status :found
      expect(session[:locality]).to eq(locality.id)
    end
  end

  describe '#reset' do
    it 'unsets the locality in the session' do
      put :reset, session: { locality: locality.id }
      expect(response).to have_http_status :found
      expect(session[:locality]).to be_nil
    end
  end
end
