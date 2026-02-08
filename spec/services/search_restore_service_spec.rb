# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchRestoreService do
  let(:search_key) { 'People::MainController' }
  let(:action) { 'index' }
  let(:session) { {} }

  describe '.call' do
    context 'when params[:reset] is present' do
      let(:params) { { reset: true } }
      let(:user) { nil }

      it 'delegates to Reset service' do
        expect(SearchRestoreService::Reset).to receive(:call).with(
          user: nil,
          session:,
          search_key:,
          action:
        )
        described_class.call(params:, user:, session:, search_key:, action:)
      end
    end

    context 'when user is present' do
      let(:user) { create(:user) }
      let(:params) { {} }

      it 'delegates to AuthenticatedUser service' do
        expect(SearchRestoreService::AuthenticatedUser).to receive(:call).with(
          params:,
          user:,
          search_key:,
          action:
        )
        described_class.call(params:, user:, session:, search_key:, action:)
      end
    end

    context 'when user is nil' do
      let(:user) { nil }
      let(:params) { {} }

      it 'delegates to GuestUser service' do
        expect(SearchRestoreService::GuestUser).to receive(:call).with(
          params:,
          session:,
          search_key:,
          action:
        )
        described_class.call(params:, user:, session:, search_key:, action:)
      end
    end

    context 'when PG::UndefinedFunction error occurs' do
      let(:user) { create(:user) }
      let(:params) { {} }

      before do
        allow(SearchRestoreService::AuthenticatedUser).to receive(:call).and_raise(PG::UndefinedFunction)
      end

      it 'rescues and calls Reset service' do
        expect(SearchRestoreService::Reset).to receive(:call).with(
          user:,
          session:,
          search_key:,
          action:
        )
        described_class.call(params:, user:, session:, search_key:, action:)
      end
    end
  end
end

RSpec.describe SearchRestoreService::Reset do
  let(:search_key) { 'People::MainController' }
  let(:action) { 'index' }
  let(:session) { {} }

  describe '.call' do
    context 'with authenticated user' do
      let(:user) { create(:user) }

      before do
        user.search_params.create!(model: search_key, params: { s: { name_eq: 'John' } })
      end

      it 'destroys the search param record' do
        expect {
          described_class.call(user:, session:, search_key:, action:)
        }.to change { user.search_params.count }.by(-1)
      end

      it 'returns redirect hash with action' do
        result = described_class.call(user:, session:, search_key:, action:)
        expect(result).to eq({ action: })
      end
    end

    context 'with guest user' do
      let(:user) { nil }

      before do
        session[:search] = { model: search_key, params: { s: { name_eq: 'John' } } }
      end

      it 'deletes session search' do
        described_class.call(user:, session:, search_key:, action:)
        expect(session[:search]).to be_nil
      end

      it 'returns redirect hash with action' do
        result = described_class.call(user:, session:, search_key:, action:)
        expect(result).to eq({ action: })
      end
    end
  end
end

RSpec.describe SearchRestoreService::AuthenticatedUser do
  let(:user) { create(:user) }
  let(:search_key) { 'People::MainController' }
  let(:action) { 'index' }

  describe '.call' do
    context 'when resetting search' do
      let(:params) { { reset: true } }

      before do
        user.search_params.create!(model: search_key, params: { s: { name_eq: 'John' } })
      end

      it 'destroys the search param record' do
        expect {
          described_class.call(params:, user:, search_key:, action:)
        }.to change { user.search_params.count }.by(-1)
      end

      it 'returns redirect hash with action' do
        result = described_class.call(params:, user:, search_key:, action:)
        expect(result).to eq({ action: })
      end
    end

    context 'when actively searching' do
      let(:params) do
        {
          s: { name_eq: 'John' },
          f: ['name', 'age'],
          scope: 'all'
        }
      end

      it 'saves search params to database' do
        expect {
          described_class.call(params:, user:, search_key:, action:)
        }.to change { user.search_params.count }.by(1)
      end

      it 'saves correct params' do
        described_class.call(params:, user:, search_key:, action:)
        search = user.search_params.find_by(model: search_key)
        expect(search.params).to eq({
          'scope' => 'all',
          's' => { 'name_eq' => 'John' },
          'f' => ['name', 'age']
        })
      end

      it 'returns nil' do
        result = described_class.call(params:, user:, search_key:, action:)
        expect(result).to be_nil
      end

      context 'with nil params' do
        let(:params) { { f: ['name'] } }

        it 'handles nil params safely' do
          expect {
            described_class.call(params:, user:, search_key:, action:)
          }.not_to raise_error
        end

        it 'saves with empty defaults for nil params' do
          described_class.call(params:, user:, search_key:, action:)
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
            described_class.call(params:, user:, search_key:, action:)
          }.not_to change { user.search_params.count }
        end

        it 'updates params' do
          described_class.call(params:, user:, search_key:, action:)
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
        result = described_class.call(params:, user:, search_key:, action:)
        expect(result).to eq(saved_params.merge(action:))
      end
    end

    context 'when no saved search exists' do
      let(:params) { {} }

      it 'returns nil' do
        result = described_class.call(params:, user:, search_key:, action:)
        expect(result).to be_nil
      end
    end

    context 'when scope is "on"' do
      let(:params) { { scope: 'on' } }

      it 'does not consider it actively searching' do
        result = described_class.call(params:, user:, search_key:, action:)
        expect(result).to be_nil
      end
    end
  end
end

RSpec.describe SearchRestoreService::GuestUser do
  let(:search_key) { 'People::MainController' }
  let(:action) { 'index' }
  let(:session) { {} }

  describe '.call' do
    context 'when resetting search' do
      let(:params) { { reset: true } }

      before do
        session[:search] = { model: search_key, params: { s: { name_eq: 'John' } } }
      end

      it 'deletes session search' do
        described_class.call(params:, session:, search_key:, action:)
        expect(session[:search]).to be_nil
      end

      it 'returns nil' do
        result = described_class.call(params:, session:, search_key:, action:)
        expect(result).to be_nil
      end
    end

    context 'when actively searching' do
      let(:params) do
        {
          s: { name_eq: 'John' },
          f: ['name', 'age'],
          scope: 'all'
        }
      end

      it 'saves search params to session' do
        described_class.call(params:, session:, search_key:, action:)
        expect(session[:search]).to eq({
          model: search_key,
          params: {
            s: { name_eq: 'John' },
            f: ['name', 'age'],
            scope: 'all'
          }
        })
      end

      it 'returns nil' do
        result = described_class.call(params:, session:, search_key:, action:)
        expect(result).to be_nil
      end

      context 'with nil params' do
        let(:params) { { f: ['name'] } }

        it 'handles nil params safely' do
          expect {
            described_class.call(params:, session:, search_key:, action:)
          }.not_to raise_error
        end

        it 'saves with empty defaults for nil params' do
          described_class.call(params:, session:, search_key:, action:)
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
        result = described_class.call(params:, session:, search_key:, action:)
        expect(result).to eq(saved_params.merge(action:))
      end
    end

    context 'when saved search has different search_key' do
      let(:params) { {} }

      before do
        session[:search] = { 'model' => 'Buildings::MainController', 'params' => { s: {} } }
      end

      it 'returns nil' do
        result = described_class.call(params:, session:, search_key:, action:)
        expect(result).to be_nil
      end
    end

    context 'when no saved search exists' do
      let(:params) { {} }

      it 'returns nil' do
        result = described_class.call(params:, session:, search_key:, action:)
        expect(result).to be_nil
      end
    end

    context 'when scope is "on"' do
      let(:params) { { scope: 'on' } }

      it 'does not consider it actively searching' do
        result = described_class.call(params:, session:, search_key:, action:)
        expect(result).to be_nil
      end
    end
  end
end
