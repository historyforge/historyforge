class BuildingSearch < SearchQueryBuilder

  def self.generate(params: {}, user: nil)
    item = self.new
    item.user = user
    item.s = params[:s] || {}
    item.f = params[:f] || item.default_fields
    item.g = params[:g] || {}
    item.c = params[:c] || 'street_address'
    item.d = params[:d] || 'asc'
    item.from = params[:from]
    item.to = params[:to]
    item.sort = params[:sort] if params[:sort]
    item.people = params[:people] if params[:people]
    item.people_params = params[:peopleParams] if params[:peopleParams]
    item.scope = params[:scope] && params[:scope] != 'on' && params[:scope].intern
    item
  end

  attr_accessor :people, :expanded

  attr_reader :people_params

  def results
    return @results if defined?(@results)

    @results = scoped.to_a
    if @residents
      @results.each do |result|
        result.residents = @residents[result.id]
      end
    end
    @results.map { |result| BuildingPresenter.new result, user }
  end

  def scoped
    return @scoped if defined?(@scoped)

    active? && builder.left_outer_joins(:addresses)

    builder.reviewed unless user
    builder.without_residents if unpeopled?
    builder.where(reviewed_at: nil) if unreviewed?
    builder.where(investigate: true) if uninvestigated?

    builder.offset(from) if from
    builder.limit(to.to_i - from.to_i) if from && to

    if expanded
      builder.includes(:building_types) if f.include?('building_type')
      builder.includes(:addresses) if f.include?('street_address')
      builder.includes(:lining_type) if f.include?('lining_type')
      builder.includes(:frame_type)  if f.include?('frame_type')
      builder.includes(:architects)  if f.include?('architects')
      add_order_clause
    end

    enrich_with_residents if people.present?

    @scoped = builder.scoped
  end

  def default_fields
    %w[street_address city state building_type year_earliest]
  end

  def all_fields
    %w[street_address city state postal_code
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

  def people_params=(params)
    people_params = JSON.parse(params)
    @people_params = people_params.each_with_object({}) do |item, hash|
      hash[item[0].to_sym] = item[1] if item[1].present?
    end
  end

  private

  def entity_class
    Building
  end

  def enrich_with_residents
    people_class = "Census#{people}Record".constantize
    people = people_class.where.not(reviewed_at: nil)

    people = people.ransack(people_params).result if people_params.present?

    return if people.blank?

    @residents = people.group_by(&:building_id)
    builder.where(id: @residents.keys)
  end

  def add_order_clause
    sort.present? ? add_applied_sort : add_default_sort
  end

  def street_address_order_clause(dir)
    "address_street_name #{dir}, address_street_prefix #{dir}, address_street_suffix #{dir}, substring(address_house_number, '^[0-9]+')::int #{dir}"
  end

  def add_applied_sort
    order = []
    sort&.each do |_key, sort_unit|
      col = sort_unit['colId']
      dir = sort_unit['sort']
      order << "#{col} #{dir}" if Building.columns.map(&:name).include?(col)
    end
    order << street_address_order_clause('asc') if order.blank?
    builder.order(entity_class.sanitize_sql_for_order(order.join(', '))) if order
  end

  def add_default_sort
    @d = 'asc' unless %w[asc desc].include?(@d)
    if @c && Building.columns.map(&:name).include?(@c)
      builder.order Arel.sql(entity_class.send(:sanitize_sql, "#{@c} #{@d}"))
    else
      builder.order Arel.sql(entity_class.send(:sanitize_sql, street_address_order_clause(@d)))
    end
  end
end
