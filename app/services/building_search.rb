class BuildingSearch

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :page, :s, :f, :g, :user, :c, :d, :sort, :paged, :per, :scope, :people, :people_params, :expanded, :from, :to
  attr_writer :scoped
  delegate :any?, :present?, :each, :first, :last,
           :current_page, :total_pages, :limit_value,
           to: :scoped

  validates :t, presence: true

  def active?
    @active
  end

  def to_a
    return @results if defined?(@results)

    @results = scoped.to_a
    if @residents
      @results.each do |result|
        result.residents = @residents[result.id]
      end
    end
    @results
  end

  # This serves the Forge
  def as_json
    sql = scoped.select("buildings.id,buildings.lat,buildings.lon").to_sql
    sql = "select array_to_json(array_agg(row_to_json(t))) as data, count(t.id) as meta from (#{sql}) t"
    data = ActiveRecord::Base.connection.execute(sql).first

    "{\"buildings\": #{data['data']}, \"meta\": {\"info\": \"All #{data['meta']} record(s)\"}}"
  end

  def ransack_params
    @s = JSON.parse(@s) if @s.is_a?(String)
    @s = @s.to_unsafe_hash if @s.respond_to?(:to_unsafe_hash)
    params = @s.each_with_object({}) { |value, hash| hash[value[0].to_sym] = value[1]; }
    params
  end

  def entity_class
    Building
  end

  def scoped
    @scoped || begin
      @f << 'investigate_reason' if uninvestigated?
      rp = ransack_params
      @active = rp.keys.any?
      rp[:reviewed_at_not_null] = 1 unless user
      @scoped = entity_class.includes(:addresses).left_outer_joins(:addresses).ransack(rp).result #.includes(:building_type, :architects).ransack(rp).result
      add_order_clause
      @scoped = @scoped.without_residents if unpeopled?
      @scoped = @scoped.where(reviewed_at: nil) if unreviewed?
      @scoped = @scoped.where(investigate: true) if uninvestigated?

      if paged?
        @scoped = @scoped.page(page).per(per).includes(:building_types)
      elsif from && to
        @scoped = @scoped.offset(from).limit(to.to_i - from.to_i).includes(:building_types)
        @scoped = @scoped.includes(:lining_type) if @f.include?('lining_type')
        @scoped = @scoped.includes(:frame_type)  if @f.include?('frame_type')
        @scoped = @scoped.includes(:architects)  if @f.include?('architects')
      end

      if expanded && people.present?
        people_class = "Census#{people}Record".constantize
        people = people_class.where.not(reviewed_at: nil)
        if people_params.present?
          q = people_params.each_with_object({}) { |item, hash|
            hash[item[0].to_sym] = item[1] if item[1].present?
          }
          people = people.ransack(q).result
        end
        if people.present?
          @residents = people.group_by(&:building_id)
          @scoped = @scoped.where(id: @residents.keys)
        end
      end
      @scoped
    end
  end

  def add_order_clause
    sort.present? ? add_applied_sort : add_default_sort
  end

  def street_address_order_clause(dir)
    "address_street_name #{dir}, address_street_prefix #{dir}, address_street_suffix #{dir}, substring(address_house_number, '^[0-9]+')::int #{dir}"
  end

  def self.generate(params: {}, user: nil, paged: true, per: 25)
    item = self.new
    item.user = user
    item.s = params[:s] || {}
    item.f = params[:f] || item.default_fields
    item.g = params[:g] || {}
    item.c = params[:c] || 'street_address'
    item.d = params[:d] || 'asc'
    if paged
      item.paged = true
      item.page = params[:page] || 1
      item.per = per
    else
      item.paged = false
      item.from = params[:from]
      item.to = params[:to]
    end
    item.sort = params[:sort] if params[:sort]
    item.people = params[:people] if params[:people]
    item.people_params = JSON.parse(params[:peopleParams]) if params[:peopleParams]
    item.scope = params[:scope] && params[:scope] != 'on' && params[:scope].intern
    item
  end

  def paged?
    paged
  end

  def columns
    @columns ||= f.concat(['id'])
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

  def is_default_field?(field)
    default_fields.include?(field.to_s)
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

  def column_def
    columns.map { |column| column_config(column) }.to_json.html_safe
  end

  def row_data(records)
    records.map do |record|
      hash = { id: record.id }
      columns.each do |column|
        value = record.field_for(column)
        value = { name: value, reviewed: record.reviewed? } if column == 'street_address'
        hash[column] = value
      end
      hash
    end.to_json.html_safe
  end

  private

  def column_config(column)
    options = {
      headerName: Translator.label(Building, column),
      field: column,
      resizable: true
    }
    options[:headerName] = 'Actions' if column == 'id'
    options[:pinned] = 'left' if %w[id street_address].include?(column)
    options[:cellRenderer] = 'actionCellRenderer' if column == 'id'
    options[:cellRenderer] = 'nameCellRenderer' if column == 'street_address'
    options[:width] = 200 if %w[name street_address description annotations].include?(column)
    options[:sortable] = true unless column == 'id'
    options
  end

  def add_applied_sort
    order = []
    sort&.each do |_key, sort_unit|
      col = sort_unit['colId']
      dir = sort_unit['sort']
      order << "#{col} #{dir}" if Building.columns.map(&:name).include?(col)
    end
    order << street_address_order_clause('asc') if order.blank?
    @scoped = @scoped.order Arel.sql(Building.send(:sanitize_sql, order.join(', ')))
  end

  def add_default_sort
    @d = 'asc' unless %w[asc desc].include?(@d)
    @scoped = if @c && Building.columns.map(&:name).include?(@c)
                @scoped.order Arel.sql(entity_class.send(:sanitize_sql, "#{@c} #{@d}"))
              else
                @scoped.order Arel.sql(entity_class.send(:sanitize_sql, street_address_order_clause(@d)))
              end
  end
end
