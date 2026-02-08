# frozen_string_literal: true

require_relative 'search_restore_service/reset'
require_relative 'search_restore_service/authenticated_user'
require_relative 'search_restore_service/guest_user'

# Service object that handles saving and restoring search parameters.
# Delegates to appropriate child service based on user state and params.
class SearchRestoreService
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
