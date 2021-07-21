class BuildingSearch

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :page, :s, :f, :fs, :g, :user, :c, :d, :sort, :paged, :per, :scope, :people, :people_params, :expanded, :from, :to
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

  def as_json
    sql = scoped.select("buildings.id,buildings.lat,buildings.lon").to_sql
    sql = "select array_to_json(array_agg(row_to_json(t))) as data, count(t.id) as meta from (#{sql}) t"
    data = ActiveRecord::Base.connection.execute(sql).first

    "{\"buildings\": #{data['data']}, \"meta\": {\"info\": \"All #{data['meta']} record(s)\"}}"
  end

  def ransack_params
    @s = JSON.parse(@s) if @s.is_a?(String)
    @s = @s.to_unsafe_hash if @s.respond_to?(:to_unsafe_hash)
    params = @s.inject({}) { |hash, value| hash[value[0].to_sym] = value[1]; hash }
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
      end

      if expanded
        if people.present?
          people_class = "Census#{people}Record".constantize
          people = people_class.where.not(reviewed_at: nil)
          if people_params.present?
            q = people_params.inject({}) {|hash, item|
              hash[item[0].to_sym] = item[1] if item[1].present?
              hash
            }
            people = people.ransack(q).result
          end
          if people.present?
            @residents = people.group_by(&:building_id)
            @scoped = @scoped.where(id: @residents.keys)
          end
        end

      end
      @scoped
    end

  end

  def add_order_clause
    if sort.present?
      order = []
      sort&.each do |_key, sort_unit|
        col = sort_unit['colId']
        dir = sort_unit['sort']
        if Building.columns.map(&:name).include?(col)
          order << "#{col} #{dir}"
        end
      end
      order << street_address_order_clause('asc') if order.blank?
      @scoped = @scoped.order Arel.sql(Building.send(:sanitize_sql, order.join(', ')))
    else
      @d = 'asc' unless %w{asc desc}.include?(@d)
      @scoped = if @c && Building.columns.map(&:name).include?(@c)
        @scoped.order Arel.sql(entity_class.send(:sanitize_sql, "#{@c} #{@d}"))
      else
        @scoped.order Arel.sql(entity_class.send(:sanitize_sql, street_address_order_clause(@d)))
      end
    end
  end

  def street_address_order_clause(dir)
    "address_street_name #{dir}, address_street_prefix #{dir}, address_street_suffix #{dir}, substring(address_house_number, '^[0-9]+')::int #{dir}"
  end

  def self.generate(params:{}, user:nil, paged:true, per: 25)
    item = new user, params[:s], params[:page], params[:f], params[:fs], params[:g], params[:c], params[:d], paged, per
    item.from = params[:from]
    item.to = params[:to]
    item.sort = params[:sort] if params[:sort]
    item.people = params[:people] if params[:people]
    item.people_params = JSON.parse(params[:peopleParams]) if params[:peopleParams]
    item.scope = params[:scope] && params[:scope] != 'on' && params[:scope].intern
    item
  end

  def initialize(user, scopes, page, fields, fieldsets, groupings, sort_col, sort_dir, paged, per)
    @user = user
    @page = page || 1
    @s = scopes || {}
    @f = fields || default_fields
    @fs = fieldsets || []
    @g = groupings || {}
    @c = sort_col || 'street_address'
    @d = sort_dir || 'asc'
    @paged = paged
    @per = per
  end

  def to_csv(csv)
    @paged = false
    require 'csv'

    headers = []

    columns.each do |field|
      headers << I18n.t("simple_form.labels.building.#{field}", default: field.humanize)
    end

    csv << CSV.generate_line(headers)

    to_a.each do |row|
      row = BuildingPresenter.new(row, user)
      row_results = []
      columns.each do |field|
        row_results << row.field_for(field)
      end
      csv << CSV.generate_line(row_results)
    end
  end

  def paged?
    !defined?(@paged) || paged
  end

  def columns
    return @columns if defined?(@columns)
    @columns = f.concat(['id'])
    # @columns ||= ([Set.new(f)] + fieldsets.map {|fs| Set.new public_send("#{fs}_fields") }).reduce(&:union)
  end

  def fieldsets
    @fs.present? ? @fs : %w{}
  end

  def default_fields
    %w{street_address city state building_type year_earliest}
  end

  def all_fields
    %w{street_address city state postal_code
       year_earliest year_latest
       description annotations stories block_number
       building_type lining_type frame_type
       architects notes latitude longitude name
    }
  end

  def all_fieldsets
    %w{}
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

  def pagination_dict(object)
    if object.respond_to?(:total_pages)
      info =  if object.total_pages < 2
                "All #{object.total_count} record(s)."
              else
                first = object.offset_value + 1
                last = object.last_page? ? object.total_count : object.offset_value + object.limit_value
                "#{first}-#{last} of #{object.total_count} records."
              end
      {
        current_page: object.current_page,
        next_page: object.next_page,
        prev_page: object.prev_page,
        total_pages: object.total_pages,
        total_count: object.total_count,
        info: info,
        paged: object.total_pages > 1
      }
    else
      {
        info: "All #{object.size} record(s).",
        total_count: object.size,
        paged: false
      }
    end
  end

  def column_def
    columns.map { |column| column_config(column) }.to_json.html_safe
  end

  def column_config(column)
    options = {
        headerName: I18n.t("simple_form.labels.building.#{column}", default: column.humanize),
        field: column,
        resizable: true
    }
    options[:headerName] = 'Actions' if column == 'id'
    options[:pinned] = 'left' if %w{id street_address}.include?(column)
    options[:cellRenderer] = 'actionCellRenderer' if column == 'id'
    options[:cellRenderer] = 'nameCellRenderer' if column == 'street_address'
    options[:width] = 200 if %w{name street_address description annotations}.include?(column)
    options[:sortable] = true unless column == 'id'
    options
  end

  def row_data(records)
    records.map do |record|
      hash = { id: record.id }
      columns.each do |column|
        value = record.field_for(column)
        if column == 'street_address'
          value = { name: value, reviewed: record.reviewed? }
        end
        hash[column] = value
      end
      hash
    end.to_json.html_safe
  end
end
