# frozen_string_literal: true

class SitemapsController < ApplicationController
  skip_before_action :check_cms_for_page

  before_action :check_public_indexing

  def index
    render_sitemap People::Sitemap.new(routes: self).index
  end

  def people
    render_sitemap People::Sitemap.new(routes: self).people(params[:shard].to_i)
  end

  private

  def render_sitemap(xml)
    return head :not_found unless xml

    render xml:
  end

  def check_public_indexing
    head :not_found unless ENV['DISALLOW_INDEXING'] != 'true' && Setting.can_people_public?
  end
end
