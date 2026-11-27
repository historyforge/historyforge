# frozen_string_literal: true

module AdvancedRestoreSearch
  extend ActiveSupport::Concern

  included do
    before_action :restore_search, only: %i[index], unless: :json_request?
  end

  private

  def grid_navigation_context(*additional_keys)
    search_params.slice(:s, :scope, :sort, *additional_keys).merge(results: '1')
  end

  def grid_navigation_params(*additional_keys)
    context = params[:navigation]
    if context.is_a?(ActionController::Parameters) && context[:results] == '1'
      return @navigation_context = context.slice(:results, :s, :scope, :sort, *additional_keys).to_unsafe_h
    end

    ExtractNavigationParams.call(user: current_user, session:, search_key:)
  end

  def restore_search
    query = request.query_parameters.with_indifferent_access
    query[:s] = SearchQueryBuilder.parse_filters(query[:s]) if query.key?(:s)
    redirect_url = RestoreAdvancedSearch.call(
      params: query,
      user: current_user,
      session:,
      search_key:,
      action: params[:action]
    )

    if redirect_url
      redirect_url = redirect_url.merge(forge_view: '1') if params[:forge_view] == '1'
      redirect_to redirect_url
    end
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
