class BuildingSearch < SearchQueryBuilder
  attr_reader :num_residents

  def self.generate(params: {}, user: nil)
    new user: user,
        s: params[:s],
        f: params[:f],
        g: params[:g],
        from: params[:from],
        to: params[:to],
        sort: params[:sort],
        people: params[:people],
        people_params: params[:peopleParams] && handle_people_params(params[:peopleParams]),
        scope: params[:scope] && params[:scope] != 'on' && params[:scope].intern
  end

  def self.handle_people_params(params)
    return if params.blank?

    JSON.parse(params).each_with_object({}) do |item, hash|
      hash[item[0].to_sym] = item[1] if item[1].present?
    end
  end

  attr_accessor :people, :expanded

  attr_reader :people_params

  memoize def results
    results = scoped.to_a
    if @residents
      results.each do |result|
        result.residents = @residents[result.id]
      end
    end

    results.map { |result| result.decorate }
  end

  memoize def scoped
    active? && builder.left_outer_joins(:addresses)

    builder.reviewed unless user
    builder.without_residents if unpeopled?
    builder.where(reviewed_at: nil) if unreviewed?
    builder.where(investigate: true) if uninvestigated?

    builder.offset(from) if from
    builder.limit(to.to_i - from.to_i) if from && to


    prepare_expanded_search if expanded
    enrich_with_residents if people.present?

    builder.scoped
  end

  def active?
    keys = ransack_params.keys
    keys.any? && keys != [:lat_not_null]
  end

  def default_fields
    %w[street_address city state building_type year_earliest]
  end

  def all_fields
    %w[street_address city state postal_code locality
       year_earliest year_latest
       description annotations stories block_number
       building_type lining_type frame_type
       architects notes latitude longitude name
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

  def prepare_expanded_search
    builder.includes(:locality) if f.include?('locality')
    builder.includes(:building_types, :building_types_buildings) if f.include?('building_type') || f.include?('building_type_name')
    builder.includes(:addresses) if f.include?('street_address')
    builder.includes(:lining_type) if f.include?('lining_type')
    builder.includes(:frame_type) if f.include?('frame_type')
    builder.includes(:architects) if f.include?('architects')
    add_order_clause
  end

  def entity_class
    Building
  end

  def enrich_with_residents
    people_class = "Census#{people}Record".constantize
    people = people_class.where.not(reviewed_at: nil).select('building_id')
    people = people.ransack(people_params).result if people_params.present?

    # Force it to return no results if there are no people - otherwise it returns all results when
    # looking for Chinese people in 1910 in Ithaca. Nobody <> everybody

    @num_residents = people.count
    builder.where(id: people)
  end

  def add_order_clause
    sort.present? ? add_applied_sort : add_default_sort
  end

  def street_address_order_clause(dir)
    builder.joins(:addresses)
    "addresses.name #{dir}, addresses.prefix #{dir}, addresses.suffix #{dir}, substring(addresses.house_number, '^[0-9]+')::int #{dir}"
  end

  def add_applied_sort
    order = []
    sort&.each do |_key, sort_unit|
      col = sort_unit['colId']
      dir = sort_unit['sort']
      if Building.columns.map(&:name).include?(col)
        order << "#{col} #{dir}"
      elsif col == 'street_address'
        order << street_address_order_clause(dir)
      end
    end
    order << street_address_order_clause('asc') if order.blank?
    builder.order(Arel.sql(entity_class.sanitize_sql_for_order(order.join(', ')))) if order
  end

  def add_default_sort
    builder.order Arel.sql(entity_class.send(:sanitize_sql, street_address_order_clause(@d)))
  end
end
