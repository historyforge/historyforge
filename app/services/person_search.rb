# frozen_string_literal: true

class PersonSearch < SearchQueryBuilder
  def self.generate(params: {}, user: nil)
    new user: user,
        entity_class: Person,
        s: params[:s],
        f: params[:f],
        g: params[:g],
        from: params[:from],
        to: params[:to],
        sort: params[:sort]
  end

  memoize def results
    scoped.to_a.map { |row| row.decorate }
  end

  memoize def scoped
    builder.offset(from) if from
    builder.limit(to.to_i - from.to_i) if from && to
    add_sorts
    builder.scoped
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
    %w[name sex race birth_year pob]
  end

  def all_fields
    default_fields
  end
end
