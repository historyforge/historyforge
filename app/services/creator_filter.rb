# frozen_string_literal: true

class CreatorFilter
  PARAM_KEYS = %i[creator_id creation_date_range creation_date_from creation_date_to].freeze
  CREATION_DATE_PRESETS = { 'today' => 1, 'last7' => 7, 'last14' => 14, 'last30' => 30, 'last90' => 90 }.freeze
  CREATION_DATE_CHOICES = [
    ['All time', 'all'], ['Today', 'today'], ['Last 7 days', 'last7'], ['Last 14 days', 'last14'],
    ['Last 30 days', 'last30'], ['Last 90 days', 'last90'], ['Custom range', 'custom'],
  ].freeze

  attr_reader :scope, :params

  def initialize(scope:, params:)
    @scope = scope
    @params = params.symbolize_keys.slice(*PARAM_KEYS)
  end

  def active?
    params[:creator_id].present?
  end

  def creation_date_range
    params[:creation_date_range].presence ||
      (params.values_at(:creation_date_from, :creation_date_to).any?(&:present?) ? 'custom' : 'all')
  end

  def selected_creator_name
    return unless scope == :all && creator_id&.positive?

    creator = User.find_by(id: creator_id)
    creator&.full_name.presence || creator&.login
  end

  def creation_date_label
    case creation_date_range
    when 'all'
      nil
    when 'custom'
      from, through = params.values_at(:creation_date_from, :creation_date_to).map(&:presence)
      if from && through
        "#{from} to #{through}"
      elsif from
        "From #{from}"
      elsif through
        "Through #{through}"
      end
    else
      CREATION_DATE_CHOICES.find { |_label, value| value == creation_date_range }&.first
    end
  end

  def apply(relation)
    return relation unless active?
    return relation.none unless creator_id&.positive? && (scope == :all || scope == creator_id)

    relation = relation.where(created_by_id: creator_id)
    filter_creation_date(relation)
  end

  private

  def creator_id
    Integer(params[:creator_id].to_s, 10, exception: false)
  end

  def filter_creation_date(relation)
    range = creation_date_range
    return relation if range == 'all'

    if range == 'custom'
      from, through = params.values_at(:creation_date_from, :creation_date_to)
      start_date = Date.iso8601(from.to_s) if from.present?
      end_date = Date.iso8601(through.to_s) if through.present?
    elsif (days = CREATION_DATE_PRESETS[range])
      end_date = Date.current
      start_date = end_date - (days - 1)
    else
      return relation.none
    end

    created_at = relation.klass.arel_table[:created_at]
    relation = relation.where(created_at.gteq(start_date.in_time_zone)) if start_date
    relation = relation.where(created_at.lt(end_date.next_day.in_time_zone)) if end_date
    relation
  rescue Date::Error
    relation.none
  end
end
