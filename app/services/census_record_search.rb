# frozen_string_literal: true

# Performs three roles that might ought to be broken out into separate classes.
# 1. Converts a hash of form parameters - filters, sorts, pagination - into an SQL query
# 2. Converts the results of the query into AgGrid-friendly hash
# 3. Converts the hash to a CSV string

class CensusRecordSearch < SearchQueryBuilder
  attr_accessor :page, :s, :f, :g, :user, :sort, :from, :to, :scope, :entity_class, :form_fields_config

  def census_scope_search?
    (@s[:enum_dist_eq].present? || entity_class.year < 1880) && @s[:page_number_eq].present? && ([1850, 1860, 1870, 1950].include?(entity_class.year) || @s[:page_side_eq].present?)
  end

  def results
    scoped.lazy.map(&:decorate)
  end
  memoize :results

  def scoped
    builder.includes(:locality) if f.include?('locality_id')
    builder.where(locality_id: Current.locality_id) if Current.locality_id && !s.key?('locality_id_in')

    builder.reviewed unless user

    builder.offset(from) if from&.positive?
    builder.limit(to - from) if from && to

    add_scopes
    add_sorts

    builder.scoped
  end
  memoize :scoped

  def add_scopes
    builder.includes(:building) if f.include?('latitude') || f.include?('longitude')
    builder.unhoused if unhoused?
    builder.unreviewed if unreviewed?
    builder.unmatched if unmatched?
  end

  def add_sorts
    if sort.blank?
      add_default_sort_order
    else
      add_custom_sort_order
    end
  end

  def add_default_sort_order
    builder.order census_page_order_clause('asc')
  end

  def add_custom_sort_order
    sort.each do |_key, sort_unit|
      col = sort_unit['colId']
      dir = sort_unit['sort']
      raise ArgumentError, "Dangerous query method!" unless %w[asc desc].include?(dir)
      order = order_clause_for(col, dir)
      builder.order(Arel.sql(entity_class.sanitize_sql_for_order(order))) if order
    end
  end

  def order_clause_for(col, dir)
    if col == 'name'
      name_order_clause(dir)
    elsif col == 'street_address'
      street_address_order_clause(dir)
    elsif col == 'census_scope'
      census_page_order_clause(dir)
    elsif col == 'family_id'
      "regexp_replace(NULLIF(family_id, ''), '[^0-9]+', '', 'g')::numeric #{dir}"
    elsif col =~ /wages/
      "regexp_replace(NULLIF(#{col}, ''), '[^0-9]+', '', 'g')::numeric #{dir}"
    elsif entity_class.columns.map(&:name).include?(col)
      "#{col} #{dir}"
    else
      raise ArgumentError, 'Unrecognized sort request.'
    end
  end

  def street_address_order_clause(dir)
    Arel.sql "street_name #{dir}, street_prefix #{dir}, street_suffix #{dir}, substring(street_house_number, '^[0-9]+')::int #{dir}"
  end

  def census_page_order_clause(dir)
    if entity_class.year < 1880
      Arel.sql "page_number #{dir}, page_side #{dir}, line_number #{dir}"
    else
      Arel.sql "ward #{dir}, regexp_replace(NULLIF(enum_dist, ''), '[^0-9]+', '', 'g')::numeric #{dir}, enum_dist #{dir}, page_number #{dir}, page_side #{dir}, line_number #{dir}"
    end
  end

  def name_order_clause(dir)
    "lower(last_name) #{dir}, lower(first_name) #{dir}, middle_name #{dir} NULLS FIRST"
  end

  def self.generate(year:, params: {}, user:)
    scope = params[:scope]
    new entity_class: "Census#{year}Record".constantize,
        form_fields_config: "Census#{year}FormFields".constantize,
        user: user,
        s: params[:s],
        f: params[:f],
        g: params[:g],
        sort: params[:sort],
        scope: scope && scope != 'on' ? scope.to_sym : nil,
        from: params[:from]&.to_i,
        to: params[:to]&.to_i
  end

  def default_fields
    %w[census_scope street_address name].tap do |fields|
      fields << 'relation_to_head' if entity_class.year >= 1880
    end.tap do |fields|
      fields.concat(%w[sex race age pob occupation])
    end
  end

  def all_fields
    CensusFieldListGenerator.new(form_fields_config).render
  end

  def unhoused?
    @scope == :unhoused
  end

  def unreviewed?
    @scope == :unreviewed
  end

  def unmatched?
    @scope == :unmatched
  end

  def facets
    form_fields_config.facets
  end
end
