# frozen_string_literal: true

# Performs three roles that might ought to be broken out into separate classes.
# 1. Converts a hash of form parameters - filters, sorts, pagination - into an SQL query
# 2. Converts the results of the query into AgGrid-friendly hash
# 3. Converts the hash to a CSV string

class CensusRecordSearch
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :page, :s, :f, :fs, :g, :user, :sort, :paged, :per, :entity_class, :from, :to, :scope

  attr_writer :scoped

  delegate :any?, :present?, :each, :first, :last,
           :current_page, :total_pages, :limit_value,
           to: :scoped

  validates :t, presence: true

  def active?
    @active
  end

  def to_a
    @to_a ||= scoped.to_a.map {|row| CensusRecordPresenter.new(row, user) }
  end

  def ransack_params
    @s = @s.to_unsafe_hash if @s.respond_to?(:to_unsafe_hash)
    @s = @s.reject { |_k, v| v == '' }
    p = Hash.new
    @s.each do |key, value|
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
    p
  end

  def scoped
    @scoped || begin
      rp = ransack_params
      @active = rp.keys.any?
      rp[:reviewed_at_not_null] = 1 unless user
      @scoped = entity_class.ransack(rp).result

      if paged?
        @scoped = @scoped.page(page).per(per)
      elsif from && to
        @scoped = @scoped.offset(from).limit(to.to_i - from.to_i)
      end

      @scoped = @scoped.includes(:locality)
      @scoped = @scoped.includes(:building) if f.include?('latitude') || f.include?('longitude')
      @scoped = @scoped.unhoused if unhoused?
      @scoped = @scoped.unreviewed if unreviewed?
      @scoped = @scoped.unmatched if unmatched?

      add_sorts
    end

  end

  def add_sorts
    order = []
    streeted = false
    censused = false
    sort&.each do |_key, sort_unit|
      col = sort_unit['colId']
      dir = sort_unit['sort']
      if col == 'name'
        order << name_order_clause(dir)
      elsif col =~ /street/
        order << street_address_order_clause(dir) unless streeted
        streeted = true
      elsif %w[census_scope ward enum_dist page_number page_size line_number].include?(col)
        order << census_page_order_clause(dir) unless censused
        censused = true
      elsif entity_class.columns.map(&:name).include?(col)
        order << "#{col} #{dir}"
      end
    end
    order << census_page_order_clause('asc') if sort.blank?
    @scoped = @scoped.order entity_class.send(:sanitize_sql, order.join(', '))
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

  def self.generate(params: {}, user:, entity_class:, paged: true, per: 25)
    item = self.new
    item.entity_class = entity_class
    item.user = user
    item.s = params[:s] || {}
    item.f = params[:f] || item.default_fields
    item.g = params[:g] || {}
    item.sort = params[:sort]
    scope = params[:scope]
    item.scope = scope.to_sym if scope && scope != 'on'
    if paged
      item.paged = true
      item.page = params[:page] || 1
      item.per = per
    else
      item.paged = false
      item.from = params[:from]
      item.to = params[:to]
    end
    item
  end

  def paged?
    !defined?(@paged) || paged
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

  def column_def
    columns.map { |column| column_config(column) }
  end

  def row_data(records)
    records.map do |record|
      columns.each_with_object({ id: record.id}) do |column, hash|
        value = record.field_for(column)
        value = { name: value, reviewed: record.reviewed? } if column == 'name'
        hash[column] = value
      end
    end
  end

  private

  def column_config(column)
    options = {
      headerName: translated_label(column), # I18n.t("simple_form.labels.census_record.#{column}", default: column.humanize),
      field: column,
      resizable: true
    }
    options[:headerName] = 'Actions' if column == 'id'
    options[:pinned] = 'left' if %w[id name].include?(column)
    options[:cellRenderer] = 'actionCellRenderer' if column == 'id'
    options[:cellRenderer] = 'nameCellRenderer' if column == 'name'
    options[:width] = 50 if %w[page_number page_side line_number age sex marital_status].include?(column)
    options[:width] = 60 if %w[id ward enum_dist dwelling_number family_id].include?(column)
    options[:width] = 130 if %w[marital_status profession industry].include?(column)
    options[:width] = 160 if %w[census_scope name street_address notes profession].include?(column)
    options[:width] = 250 if %w[coded_occupation_name coded_industry_name].include?(column)
    options[:sortable] = true unless column == 'id'
    options
  end
  
  def translated_label(key)
    Translator.label(entity_class, key)
  end
end
