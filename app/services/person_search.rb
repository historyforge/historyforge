# frozen_string_literal: true

class PersonSearch < SearchQueryBuilder
  def self.generate(params: {}, user: nil, creator_scope: nil)
    new user:,
        creator_scope:,
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
    scoped.to_a.map(&:decorate)
  end

  memoize :results

  def scoped
    builder.preload(:names) unless navigation
    builder.group("people.id")
    builder.offset(from) if from
    builder.limit(to.to_i - from.to_i) if from && to
    builder.uncensused if uncensused?
    builder.photographed if photographed?
    add_census_record_links unless navigation
    add_see_names
    add_sorts
    scope_to_locality if Current.locality_id && !s.key?("localities_id_in")
    builder.preload(:localities) if f.include?("locality_ids") && !navigation
    builder.scoped.distinct
  end

  memoize :scoped

  def count
    entity_class.where(id: unpaginated_scope.select("people.id")).count
  end

  def scope_to_locality
    builder.joins(:localities)
    builder.where(localities_people: { locality_id: Current.locality_id })
  end

  def add_census_record_links
    builder.select "people.*"
    CensusYears.each do |year|
      next unless f.include?("census#{year}")

      table = CensusRecord.for_year(year).table_name
      builder.select(builder.scoped.select_values, "(select array_agg(#{table}.id) from #{table} where person_id=people.id) AS census#{year}")
    end
  end

  def add_see_names
    return unless has_names_joined?

    builder.group("person_names.id")
    builder.select(builder.scoped.select_values, "person_names.first_name as matched_first_name, person_names.last_name as matched_last_name") unless navigation
  end

  def see_names?
    return false unless has_names_joined?

    unpaginated_scope.where.not(person_names: { last_name: [nil, ""] })
                     .where("(person_names.first_name, person_names.last_name) IS DISTINCT FROM (people.first_name, people.last_name)")
                     .exists?
  end

  def add_sorts
    order = []
    sort&.each_value do |sort_unit|
      sort_unit = sort_unit.with_indifferent_access
      col = sort_unit["colId"]
      dir = sort_unit["sort"]
      next if col == "locality_ids"

      order << if col == "name"
        name_order_clause(dir)
      else
        "#{col} #{dir}"
      end
    end
    order << name_order_clause("ASC") if sort.blank?
    builder.order(entity_class.sanitize_sql_for_order(order.join(", "))) if order
  end

  def name_order_clause(dir)
    matched = has_names_joined?
    table = matched ? 'person_names' : 'people'
    parts = matched ? %w[last_name first_name] : %w[last_name first_name middle_name]

    parts.map do |part|
      key = "sortable_#{part}"
      builder.select("LOWER(COALESCE(#{table}.#{part}, '')) AS #{key}")
      "#{key} #{dir}"
    end.join(', ')
  end

  def default_fields
    %w[name sex race birth_year death_year pob]
  end

  def all_fields
    default_fields + %w[locality_ids description] + CensusYears.map { |year| "census#{year}" }
  end

  def uncensused?
    @scope == "uncensused"
  end

  def photographed?
    @scope == "photographed"
  end

  def has_names_joined?
    relation = builder.scoped
    (relation.joins_values + relation.left_outer_joins_values).any? do |join|
      join == :names || (join.respond_to?(:reflections) && join.reflections.any? { |reflection| reflection.name == :names })
    end
  end

  private

  def unpaginated_scope
    scoped.unscope(:select, :group, :order, :limit, :offset).distinct(false)
  end

  def ransack_params
    # Keep the original filter keys in saved searches and filter chips.
    super.transform_keys do |key|
      key.to_s.sub(/\Anames_((?:first|last)_name_)/, 'names_case_insensitive_\1').to_sym
    end
  end
end
