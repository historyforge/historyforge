# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SqlInjectionProtection, type: :controller do
  controller(ApplicationController) do
    include SqlInjectionProtection

    def index
      render plain: 'success'
    end
  end

  describe '#detect_sql_injection_attempts' do
    context 'with malicious parameters' do
      it 'returns 404 for quote-based injection' do
        get :index, params: { to: '-1" OR 3+507-507-1=0+0+0+1 -- ' }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns 404 for the original attack pattern' do
        get :index, params: { to: '-1" OR 3+507-507-1=0+0+0+1 -- ' }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns 404 for comment-based injection' do
        get :index, params: { id: "1' --" }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns 404 for boolean-based injection' do
        get :index, params: { search: '1 OR 1=1' }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns 404 for stacked queries' do
        get :index, params: { query: '; DROP TABLE users;' }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with normal parameters' do
      it 'allows normal requests through' do
        get :index, params: { from: '0', to: '100' }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('success')
      end

      it 'allows numeric parameters' do
        get :index, params: { page: '1', limit: '50' }
        expect(response).to have_http_status(:ok)
      end

      it 'allows normal search terms' do
        get :index, params: { search: 'john smith' }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
