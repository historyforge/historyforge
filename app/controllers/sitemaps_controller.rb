# frozen_string_literal: true

class SitemapsController < ActionController::API
  include LoadSettings

  before_action :check_public_indexing

  def index
    render_sitemap sitemap.index
  end

  def people
    render_sitemap sitemap.people(params[:shard].to_i)
  end

  private

  def sitemap
    People::Sitemap.new(url_options: url_options.except(:_recall))
  end

  def render_sitemap(xml)
    return head :not_found unless xml

    render xml:
  end

  def check_public_indexing
    head :not_found unless ENV['DISALLOW_INDEXING'] != 'true' && Setting.can_people_public?
  end
end
