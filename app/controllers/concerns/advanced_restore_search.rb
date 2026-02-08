# frozen_string_literal: true

module AdvancedRestoreSearch
  extend ActiveSupport::Concern

  included do
    before_action :restore_search, only: %i[index], unless: :json_request?
  end

  private

  def restore_search
    redirect_url = RestoreAdvancedSearch.call(
      params:,
      user: current_user,
      session:,
      search_key:,
      action: params[:action]
    )

    redirect_to redirect_url if redirect_url
  end

  # Not restoring filters for json request because these will already have the filters
  # made available to them from the HTML page.
  def json_request?
    request.format.json?
  end

  def search_key
    self.class.name
  end
end
