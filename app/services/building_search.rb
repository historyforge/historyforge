# frozen_string_literal: true

class BuildingSearch < SearchQueryBuilder
  attr_reader :num_residents, :people_params, :near, :building_params
  attr_accessor :people, :expanded

  def self.generate(params: {}, user: nil)
    new(
      user:,
      people_params: params[:peopleParams] && parse_params(params[:peopleParams]),
      building_params: params[:buildingParams] && parse_params(params[:buildingParams]),
      scope: params[:scope] && params[:scope] != 'on' && params[:scope].intern,
      **params.slice(:s, :f, :g, :from, :to, :sort, :people, :near)
    )
  end

  def self.parse_params(params)
    return if params.blank?

    parsed_params = params.is_a?(String) ? JSON.parse(params) : params
    parsed_params.each_with_object({}) do |item, hash|
      key, value = item
      next hash if value.blank?

      hash[key.to_sym] = if value.is_a?(Hash)
                           hash[key.to_sym] = value.values
                         else
                           value
                         end
    end
  end

  def results
    results = scoped.to_a
    if @residents
      results.each do |result|
        result.residents = @residents[result.id]
      end
    end

    results.map(&:decorate)
  end

  memoize :results

  def scoped
    active? && builder.left_outer_joins(:addresses)

    builder.reviewed unless user
    builder.without_residents if unpeopled?
    builder.where(reviewed_at: nil) if unreviewed?
    builder.where(investigate: true) if uninvestigated?
    builder.where(locality_id: Current.locality_id) if Current.locality_id && !s.keys.include?('locality_id_in')

    if from
      builder.offset(from) if from.positive?
      builder.limit(to - from)
    end

    prepare_expanded_search if expanded
    enrich_with_residents if people.present?
    filter_by_distance if near

    builder.scoped
  end

  memoize :scoped

  def active?
    keys = ransack_params.keys
    keys.any? && keys != [:lat_not_null]
  end

  def default_fields
    %w[street_address locality building_type]
  end

  def all_fields
    %w[street_address city locality
       address_house_number
       address_prefix
       address_street_name
       address_suffix
       year_earliest year_latest
       description annotations stories block_number
       building_type lining frame
       architects notes latitude longitude name
       historical_addresses
    ]
  end

  def unreviewed?
    @scope == :unreviewed
  end

  def uninvestigated?
    @scope == :uninvestigated
  end

  def unpeopled?
    @scope == :unpeopled
  end

  private

  def filter_by_distance
    coordinates = near.split('+').map(&:to_d)
    builder.near(coordinates)
    builder.limit(5)
  end

  def prepare_expanded_search
    unless navigation
      builder.preload(:locality) if f.include?('locality')
      builder.preload(:addresses) if f.include?('street_address') || f.include?('historical_addresses')
      builder.preload(:architects) if f.include?('architects')
      builder.preload(:rich_text_description) if f.include?('description')
    end
    add_order_clause
  end

  def entity_class
    Building
  end

  def enrich_with_residents
    people_class = "Census#{people}Record".constantize
    people_records = people_class.where.not(reviewed_at: nil)
    people_records = people_records.ransack(people_params).result if people_params.present?
    people_records = people_records.pluck(:building_id)

    # Force it to return no results if there are no people - otherwise it returns all results when
    # looking for Chinese people in 1910 in Ithaca. Nobody <> everybody

    @num_residents = people_records.size
    builder.where(id: people_records)
  end

  def add_order_clause
    sort&.each do |_key, sort_unit|
      col = sort_unit['colId']
      dir = sort_unit['sort']
      if Building.columns.map(&:name).include?(col)
        builder.order_by(col, dir)
      elsif col == 'street_address'
        builder.order_by_street_address(dir)
      end
    end || builder.order_by_street_address('asc')
  end
end
