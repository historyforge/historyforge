# frozen_string_literal: true

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
