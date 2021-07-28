# frozen_string_literal: true

# The base class for all _search classes.
class SearchQueryBuilder
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :page, :s, :f, :g, :user, :c, :d, :sort, :paged, :per, :scope, :from, :to

  delegate :any?, :present?, :each, :first, :last,
           :current_page, :total_pages, :limit_value,
           to: :scoped

  validates :t, presence: true

  def active?
    ransack_params.keys.any?
  end

  def is_default_field?(field)
    default_fields.include?(field.to_s)
  end

  def columns
    @columns ||= f.concat(['id'])
  end

  class Builder
    def initialize(entity_class, params)
      @scoped = entity_class.ransack(params).result
    end

    attr_reader :scoped

    def method_missing(method, *args)
      if @scoped
        @scoped = @scoped.public_send(method, *args)
        # Rails.logger.info @scoped.to_sql
        # @scoped
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
    @builder ||= Builder.new entity_class, ransack_params
  end

  def ransack_params
    return @ransack_params if defined?(@ransack_params)

    s = @s.is_a?(String) ? JSON.parse(@s) : @s
    s = s.to_unsafe_hash if s.respond_to?(:to_unsafe_hash)
    @ransack_params = s.each_with_object({}) { |value, hash| hash[value[0].to_sym] = value[1]; }
  end
end
