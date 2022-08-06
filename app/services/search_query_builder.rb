# frozen_string_literal: true

# The base class for all _search classes.
class SearchQueryBuilder
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include FastMemoize

  attr_accessor :page, :s, :f, :g, :user, :c, :d, :sort, :paged, :per, :scope, :from, :to

  delegate :any?, :present?, :each, :first, :last,
           :current_page, :total_pages, :limit_value,
           to: :scoped

  validates :t, presence: true

  def initialize(*args)
    options = args.extract_options!
    options&.each do |key, value|
      instance_variable_set "@#{key}", value if value.present?
    end
    @s ||= {}
    @g ||= {}
    @f ||= default_fields
    @from = @from.to_i if @from
    @to = @to.to_i if @to
    ransack_params.keys.each do |key|
      attr = entity_class.attribute_names.detect { |item| key.to_s.starts_with?(item) }
      @f << attr if attr && !@f.include?(attr)
    end
  end

  def active?
    ransack_params.keys.any?
  end

  def default_field?(field)
    default_fields.include?(field.to_s)
  end

  def columns
    f&.concat(['id']) || []
  end
  memoize :columns

  def total_records
    scoped.count
  end

  class Builder
    def initialize(entity_class, params)
      @scoped = entity_class.ransack(params).result
    end

    attr_reader :scoped

    def method_missing(method, *args)
      if @scoped
        @scoped = @scoped.public_send(method, *args)
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
    Builder.new entity_class, ransack_params
  end
  memoize :builder

  def ransack_params
    prepare_search_filters
    p = Hash.new
    s.each do |key, value|
      if value.is_a?(Array) && value.include?('blank')
        p[:g] ||= []
        case key
        when /_not_in$/
          p[:g] << { m: 'and', key.to_sym => value, key.sub(/not_in$/, 'present').to_sym => true }
        when /_in$/
          p[:g] << { m: 'or', key.to_sym => value, key.sub(/in$/, 'present').to_sym => true }
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
    @s = @s.reject { |_k, v| v == '' }
  end
end
