class PersonSearch < SearchQueryBuilder
  def self.generate(params: {}, user: nil)
    item = new
    item.user = user
    item.s = params[:s] || {}
    item.f = params[:f] || item.default_fields
    item.g = params[:g] || {}
    item.c = params[:c] || 'name'
    item.d = params[:d] || 'asc'
    item.from = params[:from]
    item.to = params[:to]
    item.sort = params[:sort] if params[:sort]
    item
  end

  def results
    @results ||= scoped.to_a.map { |row| PersonPresenter.new(row, user) }
  end

  def scoped
    return @scoped if defined?(@scoped)

    builder.offset(from) if from
    builder.limit(to.to_i - from.to_i) if from && to
    add_sorts

    @scoped = builder.scoped
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
    %w{name sex race birth_year pob}
  end

  def all_fields
    default_fields
  end

  def entity_class
    Person
  end
end
