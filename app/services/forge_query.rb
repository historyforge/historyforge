# frozen_string_literal: true

# The Forge page has a special query for optimization purposes. This takes the standard search object and
# converts it into the optimized query, and serves the results to the controller.
class ForgeQuery
  include Memery
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  def initialize(search)
    @search = search
  end

  # This serves the Forge with a raw list of building ids with lat/lng
  def to_json(*_)
    "{\"buildings\": #{query['data'] || 'null'}, \"meta\": {\"info\": \"#{info}\"}}"
  end

  private

  attr_accessor :search

  delegate :scoped, to: :search

  def info
    if query['data'].nil?
      "Found no results"
    elsif @search.num_residents
      "Found #{pluralize_with_delimiter @search.num_residents, 'person'} in #{pluralize_with_delimiter query['meta'], 'building'}."
    else
      "Showing #{pluralize_with_delimiter query['meta'] || 0, 'building'}."
    end
  end

  def pluralize_with_delimiter(count, singular, plural = nil)
    pluralize(number_with_delimiter(count), singular, plural)
  end

  memoize def query
    sql = scoped.select("buildings.id,buildings.lat,buildings.lon").to_sql
    sql = "select array_to_json(array_agg(row_to_json(t))) as data, count(t.id) as meta from (#{sql}) t"
    ActiveRecord::Base.connection.execute(sql).first
  end
end
