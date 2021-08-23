# frozen_string_literal: true

# Performs three roles that might ought to be broken out into separate classes.
# 1. Converts a hash of form parameters - filters, sorts, pagination - into an SQL query
# 2. Converts the results of the query into AgGrid-friendly hash
# 3. Converts the hash to a CSV string

class CensusRecordSearch < SearchQueryBuilder
  attr_accessor :page, :s, :f, :g, :user, :sort, :from, :to, :scope, :entity_class, :form_fields_config

  def census_scope_search?
    @s[:enum_dist_eq].present? && @s[:page_number_eq].present? && @s[:page_side_eq].present?
  end

  memoize def results
    scoped.to_a.map {|row| row.decorate }
  end

  memoize def scoped
    builder.includes(:locality) if f.include?('locality')
    builder.reviewed unless user

    builder.offset(from) if from&.positive?
    builder.limit(to - from) if from && to

    add_scopes
    add_sorts

    builder.scoped
  end

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
      order = order_clause_for(col, dir)
      builder.order(entity_class.sanitize_sql_for_order(order)) if order
    end
  end

  def order_clause_for(col, dir)
    if col == 'name'
      name_order_clause(dir)
    elsif col == 'street_address'
      street_address_order_clause(dir)
    elsif col == 'census_scope'
      census_page_order_clause(dir)
    elsif entity_class.columns.map(&:name).include?(col)
      "#{col} #{dir}"
    end
  end

  def street_address_order_clause(dir)
    "street_name #{dir}, street_prefix #{dir}, street_suffix #{dir}, substring(street_house_number, '^[0-9]+')::int #{dir}"
  end

  def census_page_order_clause(dir)
    "ward #{dir}, enum_dist #{dir}, page_number #{dir}, page_side #{dir}, line_number #{dir}"
  end

  def name_order_clause(dir)
    "last_name #{dir}, first_name #{dir}, middle_name #{dir}"
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
    %w[census_scope name sex race age marital_status relation_to_head occupation industry pob street_address]
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
end
