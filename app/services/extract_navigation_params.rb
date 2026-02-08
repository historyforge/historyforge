# frozen_string_literal: true

# Service that extracts navigation params from saved search data.
# For navigation, only use search criteria (s, scope, sort) - not field selections (f).
# Field selections are for display purposes only and can make queries expensive.
class ExtractNavigationParams
  def self.call(user:, session:, search_key:)
    new(user:, session:, search_key:).call
  end

  def initialize(user:, session:, search_key:)
    @user = user
    @session = session
    @search_key = search_key
  end

  def call
    search_data = fetch_search_data
    return nil unless search_data.present? && search_data[:s].present?

    params = {
      s: search_data[:s] || search_data['s'],
      scope: search_data[:scope] || search_data['scope'],
      sort: search_data[:sort] || search_data['sort']
    }.compact

    return nil if params.empty? || params[:s].blank?

    params
  end

  private

  attr_reader :user, :session, :search_key

  def fetch_search_data
    if user
      user.search_params.find_by(model: search_key)&.params&.deep_symbolize_keys
    else
      session[:searches]&.dig(search_key)&.deep_symbolize_keys
    end
  end
end
