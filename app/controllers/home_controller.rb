# frozen_string_literal: true

class HomeController < ApplicationController

  before_action :load_announcement, only: :index

  def index
    @html_title = 'Home - HistoryForge'
  end

  def stats
    @stats = CensusStats.new
  end

  def saved_searches; end

  def search_people
    @names = Person.name_fuzzy_matches(params[:term]).limit(10)
    render json: @names.map { |p| { url: url_for(p), year: p.birth_year, name: p.name, sex: p.sex } }
  end

  def search_buildings
    @buildings = Building.joins(:addresses).includes(:addresses).ransack(street_address_cont: params[:term]).result
    @buildings = @buildings.limit(10) unless params[:unpaged]
    if params[:unpaged] && params[:term].size > 3
      @names = PgSearch::Document.ransack(content_cont: params[:term])
                                 .result.includes(searchable: { building: :addresses })
                                 .map(&:searchable)
                                 .map(&:building)
                                 .compact
                                 .uniq
      @buildings = @buildings.to_a.concat(@names)
    end
    render json: @buildings.map { |b| { url: url_for(b), id: b.id, name: b.full_street_address, lat: b.latitude, lon: b.longitude } }
  end

  private

  def load_announcement
    return unless AppConfig[:announcement_show]

    @announcement = {
      text: AppConfig[:announcement_text],
      url: AppConfig[:announcement_url]
    }
  end
end
