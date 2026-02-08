# frozen_string_literal: true

class SearchRestoreService
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
        session.delete(:search)
      end

      { action: }
    end

    private

    attr_reader :user, :session, :search_key, :action
  end
end
