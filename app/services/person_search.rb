# frozen_string_literal: true

class PersonSearch < SearchQueryBuilder
  def self.generate(params: {}, user: nil)
    new user:,
        entity_class: Person,
        s: params[:s],
        f: params[:f],
        g: params[:g],
        from: params[:from],
        to: params[:to],
        sort: params[:sort],
        scope: params[:scope]
  end

  attr_accessor :scope

  def entity_class
    Person
  end

  def results
    scoped.to_a.map { |row| row.decorate }
  end
  memoize :results

  def scoped
    builder.offset(from) if from
    builder.limit(to.to_i - from.to_i) if from && to
    builder.uncensused if uncensused?
    builder.photographed if photographed?
    add_census_record_links
    add_sorts
    builder.scoped
  end
  memoize :scoped

  def count
    builder.uncensused if uncensused?
    builder.photographed if photographed?
    builder.scoped.count
  end

  def add_census_record_links
    builder.select 'people.*'
    CensusYears.each do |year|
      next unless f.include?("census#{year}")

      builder.left_outer_joins(:"census#{year}_record")
      table = CensusRecord.for_year(year).table_name
      builder.select(builder.scoped.select_values, "#{table}.id AS census#{year}")
    end
  end

  def add_sorts
    order = []
    sort&.each do |_key, sort_unit|
      col = sort_unit['colId']
      dir = sort_unit['sort']
      order << if col == 'name'
                 name_order_clause(dir)
               else
                 "#{col} #{dir}"
               end
    end
    order << name_order_clause('asc') if sort.blank?
    builder.order(entity_class.sanitize_sql_for_order(order.join(', '))) if order
  end

  def name_order_clause(dir)
    "last_name #{dir}, first_name #{dir}, middle_name #{dir}"
  end

  def default_fields
    %w[name sex race birth_year pob census1880 census1900 census1910 census1920 census1930 census1940 census1950]
  end

  def all_fields
    default_fields
  end

  def uncensused?
    @scope == 'uncensused'
  end

  def photographed?
    @scope == 'photographed'
  end
end
