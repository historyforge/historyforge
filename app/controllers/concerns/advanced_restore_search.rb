# frozen_string_literal: true

module AdvancedRestoreSearch
  extend ActiveSupport::Concern

  included do
    before_action :restore_search, only: %i[index], unless: :json_request?
    memoize :current_search_data
  end

  private

  def restore_search
    redirect_url = SearchRestoreService.call(
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

  def current_search_data
    if current_user
      current_user.search_params.find_by(model: search_key)&.params&.deep_symbolize_keys
    else
      session[:search]&.dig("params")&.deep_symbolize_keys if session[:search]&.dig("model") == search_key
    end
  end

  def has_active_search_data?
    current_search_data.present? && current_search_data[:s].present?
  end
end
