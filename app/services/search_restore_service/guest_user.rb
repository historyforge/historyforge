# frozen_string_literal: true

class SearchRestoreService
  class GuestUser
    def self.call(params:, session:, search_key:, action:)
      new(params:, session:, search_key:, action:).call
    end

    def initialize(params:, session:, search_key:, action:)
      @params = params
      @session = session
      @search_key = search_key
      @action = action
    end

    def call
      if resetting_search?
        session.delete(:search)
        nil
      elsif actively_searching?
        session[:search] = {
          model: search_key,
          params: params_to_save,
        }
        nil
      elsif session[:search] && session[:search]['model'] == search_key
        session[:search]['params'].deep_symbolize_keys.merge(action:)
      else
        nil
      end
    end

    private

    attr_reader :params, :session, :search_key, :action

    def resetting_search?
      params[:reset]
    end

    def actively_searching?
      params[:s] || params[:f] || (params[:scope] && params[:scope] != 'on')
    end

    def params_to_save
      {
        s: params[:s]&.dup || params[:s] || {},
        f: params[:f]&.dup || params[:f] || [],
        scope: params[:scope]&.dup || params[:scope],
      }
    end
  end
end
