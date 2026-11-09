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
      fields = user ? reset_user_search : reset_guest_search
      fields ? { action:, f: fields } : { action: }
    end

    private

    attr_reader :user, :session, :search_key, :action

    def reset_user_search
      search = user.search_params.find_by(model: search_key)
      fields = search&.params&.fetch('f', nil).presence
      if fields
        search.update!(params: { f: fields })
      else
        search&.destroy
      end
      fields
    end

    def reset_guest_search
      searches = session[:searches]
      fields = searches&.dig(search_key)&.with_indifferent_access&.fetch(:f, nil).presence
      if fields
        searches[search_key] = { f: fields }
      else
        searches&.delete(search_key)
      end
      fields
    end
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

      if actively_searching?
        fields = search.params&.fetch('f', nil)
        return { action:, params: params.merge(f: fields) } if !params.key?(:f) && fields.present?

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
      saved_params = session[:searches]&.dig(search_key)&.with_indifferent_access
      if actively_searching?
        fields = saved_params&.fetch(:f, nil)
        return { action:, params: params.merge(f: fields) } if !params.key?(:f) && fields.present?

        session[:searches] ||= {}
        session[:searches][search_key] = params_to_save
        nil
      else
        saved_params&.deep_symbolize_keys&.merge(action:)
      end
    end

    private

    attr_reader :params, :session, :search_key, :action

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
