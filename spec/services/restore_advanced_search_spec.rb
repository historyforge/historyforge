# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RestoreAdvancedSearch do
  let(:search_key) { 'People::MainController' }
  let(:action) { 'index' }
  let(:session) { {} }

  describe '.call' do
    context 'when params[:reset] is present' do
      let(:params) { { reset: true } }

      context 'with authenticated user' do
        let(:user) { create(:user) }

        before do
          user.search_params.create!(model: search_key, params: { s: { name_eq: 'John' } })
        end

        it 'destroys the search param and returns redirect hash' do
          expect {
            result = described_class.call(params:, user:, session:, search_key:, action:)
            expect(result).to eq({ action: })
          }.to change { user.search_params.count }.by(-1)
        end
      end

      context 'with guest user' do
        let(:user) { nil }

        before do
          session[:search] = { model: search_key, params: { s: { name_eq: 'John' } } }
        end

        it 'deletes session search and returns redirect hash' do
          result = described_class.call(params:, user:, session:, search_key:, action:)
          expect(session[:search]).to be_nil
          expect(result).to eq({ action: })
        end
      end
    end

    context 'when user is present (authenticated)' do
      let(:user) { create(:user) }

      context 'when actively searching' do
        let(:params) do
          {
            s: { name_eq: 'John' },
            f: ['name', 'age'],
            scope: 'all'
          }
        end

        it 'saves search params to database and returns nil' do
          expect {
            result = described_class.call(params:, user:, session:, search_key:, action:)
            expect(result).to be_nil
          }.to change { user.search_params.count }.by(1)

          search = user.search_params.find_by(model: search_key)
          expect(search.params).to eq({
            'scope' => 'all',
            's' => { 'name_eq' => 'John' },
            'f' => ['name', 'age']
          })
        end

        context 'with nil params' do
          let(:params) { { f: ['name'] } }

          it 'handles nil params safely with empty defaults' do
            expect {
              result = described_class.call(params:, user:, session:, search_key:, action:)
              expect(result).to be_nil
            }.not_to raise_error

            search = user.search_params.find_by(model: search_key)
            expect(search.params['s']).to eq({})
            expect(search.params['scope']).to be_nil
          end
        end

        context 'with existing search param' do
          before do
            user.search_params.create!(model: search_key, params: { s: { old: 'value' } })
          end

          it 'updates existing search param' do
            expect {
              result = described_class.call(params:, user:, session:, search_key:, action:)
              expect(result).to be_nil
            }.not_to change { user.search_params.count }

            search = user.search_params.find_by(model: search_key)
            expect(search.params['s']).to eq({ 'name_eq' => 'John' })
          end
        end
      end

      context 'when restoring saved search' do
        let(:params) { {} }
        let(:saved_params) do
          {
            s: { name_eq: 'John' },
            f: ['name', 'age'],
            scope: 'all'
          }
        end

        before do
          user.search_params.create!(model: search_key, params: saved_params)
        end

        it 'returns redirect hash with saved params and action' do
          result = described_class.call(params:, user:, session:, search_key:, action:)
          expect(result).to eq(saved_params.merge(action:))
        end
      end

      context 'when no saved search exists' do
        let(:params) { {} }

        it 'returns nil' do
          result = described_class.call(params:, user:, session:, search_key:, action:)
          expect(result).to be_nil
        end
      end

      context 'when scope is "on"' do
        let(:params) { { scope: 'on' } }

        it 'does not consider it actively searching and returns nil' do
          result = described_class.call(params:, user:, session:, search_key:, action:)
          expect(result).to be_nil
        end
      end
    end

    context 'when user is nil (guest)' do
      let(:user) { nil }

      context 'when actively searching' do
        let(:params) do
          {
            s: { name_eq: 'John' },
            f: ['name', 'age'],
            scope: 'all'
          }
        end

        it 'saves search params to session and returns nil' do
          result = described_class.call(params:, user:, session:, search_key:, action:)
          expect(result).to be_nil
          expect(session[:search]).to eq({
            model: search_key,
            params: {
              s: { name_eq: 'John' },
              f: ['name', 'age'],
              scope: 'all'
            }
          })
        end

        context 'with nil params' do
          let(:params) { { f: ['name'] } }

          it 'handles nil params safely with empty defaults' do
            expect {
              result = described_class.call(params:, user:, session:, search_key:, action:)
              expect(result).to be_nil
            }.not_to raise_error

            expect(session[:search][:params][:s]).to eq({})
            expect(session[:search][:params][:scope]).to be_nil
          end
        end
      end

      context 'when restoring saved search' do
        let(:params) { {} }
        let(:saved_params) do
          {
            s: { name_eq: 'John' },
            f: ['name', 'age'],
            scope: 'all'
          }
        end

        before do
          session[:search] = { 'model' => search_key, 'params' => saved_params }
        end

        it 'returns redirect hash with saved params and action' do
          result = described_class.call(params:, user:, session:, search_key:, action:)
          expect(result).to eq(saved_params.merge(action:))
        end
      end

      context 'when saved search has different search_key' do
        let(:params) { {} }

        before do
          session[:search] = { 'model' => 'Buildings::MainController', 'params' => { s: {} } }
        end

        it 'returns nil' do
          result = described_class.call(params:, user:, session:, search_key:, action:)
          expect(result).to be_nil
        end
      end

      context 'when no saved search exists' do
        let(:params) { {} }

        it 'returns nil' do
          result = described_class.call(params:, user:, session:, search_key:, action:)
          expect(result).to be_nil
        end
      end

      context 'when scope is "on"' do
        let(:params) { { scope: 'on' } }

        it 'does not consider it actively searching and returns nil' do
          result = described_class.call(params:, user:, session:, search_key:, action:)
          expect(result).to be_nil
        end
      end
    end

  end
end
