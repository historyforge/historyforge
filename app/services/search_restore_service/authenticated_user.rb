# frozen_string_literal: true

class SearchRestoreService
  class AuthenticatedUser
    def self.call(params:, user:, search_key:, action:)
      new(params:, user:, search_key:, action:).call
    end

    def initialize(params:, user:, search_key:, action:)
      @params = params
      @user = user
      @search_key = search_key
      @action = action
    end

    def call
      search = user.search_params.find_or_initialize_by(model: search_key)

      if resetting_search?
        search&.destroy
        { action: }
      elsif actively_searching?
        search.params = params_to_save
        search.save
        nil
      elsif search.persisted?
        search.params.deep_symbolize_keys.merge(action:)
      else
        nil
      end
    end

    private

    attr_reader :params, :user, :search_key, :action

    def resetting_search?
      params[:reset]
    end

    def actively_searching?
      params[:s] || params[:f] || (params[:scope] && params[:scope] != 'on')
    end

    def params_to_save
      {
        scope: params[:scope]&.dup || params[:scope],
        s: params[:s]&.dup || params[:s] || {},
        f: params[:f]&.dup || params[:f] || [],
      }
    end
  end
end
