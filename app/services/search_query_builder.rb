# frozen_string_literal: true

# The base class for all _search classes.
class SearchQueryBuilder
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include FastMemoize

  OPERATOR_FILTER_KEYS = %i[operator_id operator_created_from operator_created_to].freeze

  attr_accessor :page, :s, :f, :g, :user, :c, :d, :sort, :paged, :per, :scope, :from, :to, :navigation
  attr_reader :operator_scope

  delegate :any?, :present?, :each, :first, :last,
           :current_page, :total_pages, :limit_value, :count,
           to: :scoped

  validates :t, presence: true

  def initialize(*args)
    options = args.extract_options!
    options&.each do |key, value|
      instance_variable_set :"@#{key}", value if value.present?
    end
    @s ||= {}
    @g ||= {}
    @f = default_fields if @f.blank? || @f.is_a?(String)
    @f = @f.values if @f.is_a?(Hash) # Shouldn't be a hash but somehow possible...
    @from = @from.to_i if @from
    @to = @to.to_i if @to
    ransack_params.each_key do |key|
      attr = entity_class.attribute_names.detect { |item| key.to_s.starts_with?(item) }
      @f << attr if attr && @f&.exclude?(attr)
    end
  end

  def active?
    operator_filter_active? || ransack_params.keys.any?
  end

  def operator_filter_active?
    operator_filters[:operator_id].present?
  end

  def operator_filters
    s.symbolize_keys.slice(*OPERATOR_FILTER_KEYS)
  end

  memoize :operator_filters

  def selected_operator_name
    return unless operator_scope == :all && operator_filter_active?

    operator_id = Integer(operator_filters[:operator_id].to_s, 10, exception: false)
    operator = User.find_by(id: operator_id) if operator_id&.positive?
    operator&.full_name.presence || operator&.login
  end

  def default_field?(field)
    default_fields.include?(field.to_s)
  end

  def columns
    f&.concat(["id"]) || []
  end

  memoize :columns

  def total_records
    count
  end

  def navigation_neighbors(current_id)
    return nil unless current_id

    @navigation = true

    # Get the ordered list of IDs from the main query (respects all filters and sorting)
    base_query = scoped.offset(nil).limit(nil)

    # Ensure the base query includes id in its select list
    base_query = base_query.select("#{entity_class.table_name}.*") unless base_query.select_values.include?("#{entity_class.table_name}.id")

    # Wrap the base query in another query that just selects the IDs
    sql = "SELECT id FROM (#{base_query.to_sql}) AS subquery"
    ordered_ids = entity_class.connection.execute(sql).pluck("id")

    # Find the current position in the ordered list
    current_index = ordered_ids.index(current_id)
    return nil unless current_index

    # Get previous and next IDs
    {
      previous_id: current_index > 0 ? ordered_ids[current_index - 1] : nil,
      next_id: current_index < ordered_ids.length - 1 ? ordered_ids[current_index + 1] : nil,
    }
  end

  class Builder
    def initialize(entity_class, params)
      @scoped = entity_class.ransack(params).result
    end

    attr_reader :scoped

    def method_missing(method, *)
      if @scoped
        @scoped = @scoped.public_send(method, *)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @scoped.send :respond_to_missing?, method_name, include_private
    end
  end

  private

  def builder
    Builder.new(entity_class, ransack_params).tap do |query|
      filter_by_operator(query) if operator_filter_active?
    end
  end

  memoize :builder

  def filter_by_operator(query)
    filters = operator_filters
    operator_id = Integer(filters[:operator_id].to_s, 10, exception: false)
    return query.none unless operator_id&.positive?
    return query.none unless @operator_scope == :all || @operator_scope == operator_id

    if entity_class == Person
      # Keep the partial index predicate literal so generic prepared plans can use it.
      creations = Person.paper_trail.version_class
                        .where("item_type = 'Person' AND event = 'create'")
                        .where(whodunnit: operator_id.to_s)
      query.where(id: creations.select(:item_id))
    else
      query.where(entity_class.table_name => { created_by_id: operator_id })
    end

    created_at = entity_class.arel_table[:created_at]
    if filters[:operator_created_from].present?
      start_date = Date.iso8601(filters[:operator_created_from].to_s)
      query.where(created_at.gteq(start_date.in_time_zone))
    end
    if filters[:operator_created_to].present?
      end_date = Date.iso8601(filters[:operator_created_to].to_s)
      query.where(created_at.lt((end_date + 1.day).in_time_zone))
    end
  rescue Date::Error
    query.none
  end

  def ransack_params
    prepare_search_filters
    p = {}
    s.each do |key, value|
      next if OPERATOR_FILTER_KEYS.include?(key.to_sym)

      if value.is_a?(Array) && value.include?("blank")
        p[:g] ||= []
        case key
        when /_not_in$/
          p[:g] << { m: "and", key.to_sym => value, key.sub(/not_in$/, "present").to_sym => true }
        when /_in$/
          p[:g] << { m: "or", key.to_sym => value, key.sub(/in$/, "present").to_sym => true }
        end
      else
        p[key.to_sym] = value
      end
    end
    p
  end

  memoize :ransack_params

  def prepare_search_filters
    @s = @s.is_a?(String) ? JSON.parse(@s) : @s
    @s = @s.respond_to?(:to_unsafe_hash) ? @s.to_unsafe_hash : @s
    @s = @s.reject { |_k, v| v == "" }
    @s.transform_values! do |value|
      case value
      when String
        value.squish
      when Array
        value.map { |v| v.is_a?(String) ? v.squish : v }
      when Hash
        # Convert nested hash like {"0" => "2"} to array ["2"]
        value.values.map { |v| v.is_a?(String) ? v.squish : v }
      else
        value
      end
    end
  end
end
