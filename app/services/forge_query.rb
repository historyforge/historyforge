# frozen_string_literal: true

# The Forge page has a special query for optimization purposes. This takes the standard search object and
# converts it into the optimized query, and serves the results to the controller.
class ForgeQuery
  def initialize(search)
    @search = search
  end

  # This serves the Forge with a raw list of building ids with lat/lng
  def to_json(*_)
    "{\"buildings\": #{query['data']}, \"meta\": {\"info\": \"All #{query['meta']} record(s)\"}}"
  end

  private

  attr_accessor :search

  delegate :scoped, to: :search

  def query
    return @query if defined?(@query)

    sql = scoped.select("buildings.id,buildings.lat,buildings.lon").to_sql
    sql = "select array_to_json(array_agg(row_to_json(t))) as data, count(t.id) as meta from (#{sql}) t"
    @query = ActiveRecord::Base.connection.execute(sql).first
  end
end
