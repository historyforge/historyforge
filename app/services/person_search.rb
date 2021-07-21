class PersonSearch
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :page, :s, :f, :fs, :g, :user, :sort, :paged, :per, :entity_class, :from, :to
  attr_writer :scoped
  delegate :any?, :present?, :each, :first, :last,
           :current_page, :total_pages, :limit_value,
           to: :scoped

  validates :t, presence: true

  def active?
    @active
  end

  def to_a
    @results ||= scoped.to_a.map {|row| PersonPresenter.new(row, user) }
  end

  def ransack_params
    @s = @s.to_unsafe_hash if @s.respond_to?(:to_unsafe_hash)
    @s = @s.reject { |_k, v| v == '' }
    @s.each_with_object({}) { |value, hash| hash[value[0].to_sym] = value[1] }
  end

  def scoped
    @scoped || begin
                 rp = ransack_params
                 @active = rp.keys.any?
                 rp[:reviewed_at_not_null] = 1 unless user
                 @scoped = Person.ransack(rp).result
                 if paged?
                   @scoped = @scoped.page(page).per(per)
                 elsif from && to
                   @scoped = @scoped.offset(from).limit(to.to_i - from.to_i)
                 end
                 add_sorts
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
    @scoped = @scoped.order Person.send(:sanitize_sql, order.join(', '))
  end

  def name_order_clause(dir)
    "last_name #{dir}, first_name #{dir}, middle_name #{dir}"
  end

  def self.generate(params: {}, user:nil, paged:true, per: 25)
    new user, params[:s], params[:page], params[:f], params[:fs], params[:g], params[:sort], paged, per, params[:from], params[:to]
  end

  def initialize(user, scopes, page, fields, fieldsets, groupings, sort, paged, per, from, to)
    @user = user
    @page = page || 1
    @s = scopes || {}
    @f = fields || default_fields
    @fs = fieldsets || []
    @g = groupings || {}
    @sort = sort
    @paged = paged
    @per = per
    @from = from
    @to = to
  end

  def to_csv(csv)
    @paged = false
    require 'csv'

    headers = ['ID']
    columns.each do |field|
      headers << I18n.t("simple_form.labels.person.#{field}", default: field.humanize)
    end
    csv << CSV.generate_line(headers)

    to_a.each do |row|
      row_results = [row.id]
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
    @columns = (fieldsets.map { |fs|
      method = "#{fs}_fields"
      respond_to?(method) ? Set.new(public_send(method)) : nil
    }.compact + [Set.new(f)]).reduce(&:union)
    @columns = @columns.to_a
    @columns << 'id'
    @columns
  end

  def fieldsets
    @fs.present? ? @fs : %w{census_scope}
  end

  def default_fields
    %w{name sex race birth_year pob}
  end

  def all_fields
    default_fields
    # %w{}
  end

  def all_fieldsets
    %w{}
  end

  def is_default_field?(field)
    default_fields.include?(field.to_s)
  end

  def column_def
    columns.map { |column| column_config(column) }
  end

  def column_config(column)
    options = {
        headerName: I18n.t("simple_form.labels.person.#{column}", default: column.humanize),
        field: column,
        resizable: true
    }
    options[:headerName] = 'Actions' if column == 'id'
    options[:pinned] = 'left' if %w{id name}.include?(column)
    options[:cellRenderer] = 'actionCellRenderer' if column == 'id'
    options[:cellRenderer] = 'nameCellRenderer' if column == 'name'
    options[:width] = 50 if %w{race age sex marital_status}.include?(column)
    options[:width] = 130 if %w{profession industry}.include?(column)
    options[:width] = 160 if %w{name street_address notes profession}.include?(column)
    options[:width] = 250 if %w{coded_occupation_name coded_industry_name}.include?(column)
    options[:sortable] = true unless column == 'id'
    options
  end

  def row_data(records)
    records.map do |record|
      columns.each_with_object({id: record.id}) do |column, hash|
        value = record.field_for(column)
        if column == 'name'
          value = { name: value, reviewed: record.reviewed? }
        end
        hash[column] = value
      end
    end
  end
end
