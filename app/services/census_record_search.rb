# frozen_string_literal: true

# Performs three roles that might ought to be broken out into separate classes.
# 1. Converts a hash of form parameters - filters, sorts, pagination - into an SQL query
# 2. Converts the results of the query into AgGrid-friendly hash
# 3. Converts the hash to a CSV string

class CensusRecordSearch < SearchQueryBuilder
  attr_accessor :page, :s, :f, :fs, :g, :user, :sort, :from, :to, :scope

  def results
    @results ||= scoped.to_a.map {|row| CensusRecordPresenter.new(row, user) }
  end

  def ransack_params
    return @ransack_params if defined?(@ransack_params)
    s = @s.respond_to?(:to_unsafe_hash) ? @s.to_unsafe_hash : @s
    s = s.reject { |_k, v| v == '' }
    p = Hash.new
    s.each do |key, value|
      if value.is_a?(Array) && value.include?('blank')
        p[:g] ||= []
        if key =~ /_not_in$/
          p[:g] << { m: 'and', key.to_sym => value, key.sub(/not_in$/, 'present').to_sym => true }
        elsif key =~ /_in$/
          p[:g] << { m: 'or', key.to_sym => value, key.sub(/in$/, 'present').to_sym => true }
        end
      else
        p[key.to_sym] = value
      end
    end
    @ransack_params = p
  end

  def scoped
    return @scoped if defined?(@scoped)

    builder.includes(:locality)
    builder.reviewed unless user

    builder.offset(from) if from
    builder.limit(to.to_i - from.to_i) if from && to

    add_scopes
    add_sorts

    @scoped = builder.scoped
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

  def self.generate(params: {}, user:, paged: true, per: 25)
    item = self.new
    item.user = user
    item.s = params[:s] || {}
    item.f = params[:f] || item.default_fields
    item.g = params[:g] || {}
    item.sort = params[:sort]
    scope = params[:scope]
    item.scope = scope.to_sym if scope && scope != 'on'
    item.from = params[:from]
    item.to = params[:to]

    item
  end

  def columns
    @columns ||= f.concat(['id'])
  end

  def default_fields
    %w[]
  end

  def all_fields
    %w[]
  end

  def is_default_field?(field)
    default_fields.include?(field.to_s)
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

  private
end
