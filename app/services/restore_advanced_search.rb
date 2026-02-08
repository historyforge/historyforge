# frozen_string_literal: true

# Service object that handles saving and restoring search parameters.
# Delegates to appropriate child service based on user state and params.
class RestoreAdvancedSearch
  class Reset
    def self.call(user:, session:, search_key:, action:)
      new(user:, session:, search_key:, action:).call
    end

    def initialize(user:, session:, search_key:, action:)
      @user = user
      @session = session
      @search_key = search_key
      @action = action
    end

    def call
      if user
        search = user.search_params.find_or_initialize_by(model: search_key)
        search&.destroy
      else
        session[:searches]&.delete(search_key)
      end

      { action: }
    end

    private

    attr_reader :user, :session, :search_key, :action
  end

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
        sort: params[:sort]&.dup || params[:sort],
      }
    end
  end

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
        session[:searches]&.delete(search_key)
        nil
      elsif actively_searching?
        session[:searches] ||= {}
        session[:searches][search_key] = params_to_save
        nil
      else
        saved_params = session[:searches]&.dig(search_key)
        saved_params&.deep_symbolize_keys&.merge(action:) if saved_params
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
        sort: params[:sort]&.dup || params[:sort],
      }
    end
  end

  def self.call(params:, user:, session:, search_key:, action:)
    if params[:reset]
      Reset.call(user:, session:, search_key:, action:)
    elsif user
      AuthenticatedUser.call(params:, user:, search_key:, action:)
    else
      GuestUser.call(params:, session:, search_key:, action:)
    end
  rescue PG::UndefinedFunction
    # Handle corrupted saved searches by resetting
    Reset.call(user:, session:, search_key:, action:)
  end
end
