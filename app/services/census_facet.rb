# frozen_string_literal: true

class CensusFacet
  UNKNOWN_VALUES = %w[unknown un unk].freeze
  CALENDAR_FIELDS = %i[birth_month marriage_month].freeze

  def initialize(search, facet)
    @search = search
    @facet = facet.to_s.to_sym
    raise ArgumentError, 'Unsupported census summary field' unless search.facets.include?(@facet)
  end

  def calculate
    counts = recorded_counts
    blank = counts.delete(nil).to_i
    unknown = 0
    rows = Hash.new(0)
    counts.each do |value, count|
      if value.is_a?(String) && value.strip.empty?
        blank += count
      elsif unknown?(value)
        unknown += count
      else
        rows[value] += count
      end
    end

    matching = rows.values.sum + blank + unknown
    chart_rows = if calendar_months?
      (1..12).map { |month| [Date::MONTHNAMES.fetch(month), rows[month]] }
    elsif school_months?
      (0..12).map { |month| [month, rows[month]] }
    elsif buckets
      grouped_rows(rows)
    else
      categorical_rows(rows)
    end
    included = chart_rows.sum(&:last)
    {
      rows: chart_rows, included:, matching:, blank:, unknown:,
      outside_range: matching - blank - unknown - included,
      chart: buckets || calendar_months? || school_months? ? :bar : :pie,
      explanation: options[:demographics_explanation],
      description: field_description,
      conditional: school_months? || options[:depends_on].present? ||
        (@search.entity_class.year == 1950 && options[:if].present?)
    }
  end

  private

  def recorded_counts
    scope = @search.scoped.except(:order, :limit, :offset, :includes)
    return scope.group(@facet).count unless @facet == :age && @search.entity_class.column_names.include?('age_months')

    scope.group(:age, :age_months).count.each_with_object(Hash.new(0)) do |((years, months), count), ages|
      age = if months == 12 && (years.nil? || years.zero?)
        1
      elsif years.nil? && (0..11).cover?(months)
        0
      elsif years.nil? && months == 999
        999
      else
        years
      end
      ages[age] += count
    end
  end

  def options
    @options ||= @search.form_fields_config.options_for(@facet)
  end

  def field_description
    I18n.t("#{@search.entity_class.year}.#{@facet}", scope: :census_summary_fields,
           default: [:"defaults.#{@facet}", '']).presence
  end

  def unknown?(value)
    UNKNOWN_VALUES.include?(value.to_s.strip.downcase) || ((@facet == :age || calendar_months?) && value == 999)
  end

  def calendar_months?
    CALENDAR_FIELDS.include?(@facet)
  end

  def school_months?
    @facet == :attended_school && @search.entity_class.year == 1900
  end

  def categorical_rows(rows)
    ranks = choice_ranks
    ordered = rows.map do |value, count|
      label = label_for(value)
      sort_value = income_amount? ? value : label
      key = [ranks.fetch(value.to_s.downcase, ranks.size), natural_order(sort_value)]
      [key, label, count]
    end.sort_by(&:first)
    ordered.each_with_object(Hash.new(0)) do |(_, label, count), labels|
      labels[label] += count
    end.to_a
  end

  def label_for(value)
    case options[:as]
    when :boolean then value ? 'Yes' : 'No'
    when :radio_buttons, :radio_buttons_other
      attribute = options[:coded].is_a?(Symbol) ? options[:coded] : @facet
      Translator.option(attribute, value.to_s)
    else value
    end
  end

  def choice_ranks
    return { 'true' => 0, 'false' => 1 } if options[:as] == :boolean
    return {} if income_amount?

    Array(options[:collection]).map { |choice| Array(choice).last.to_s.downcase }.each_with_index.to_h
  end

  def income_amount?
    @search.entity_class.income_amount_fields.include?(@facet)
  end

  def natural_order(value)
    return [[0, value]] if value.is_a?(Numeric)

    value.to_s.downcase.scan(/\d+|\D+/).map { |part| part.match?(/\A\d/) ? [0, part.to_i] : [1, part] }
  end

  def grouped_rows(rows)
    from, to, step = buckets
    counts = Hash.new(0)
    rows.each do |value, count|
      next unless value >= from && value < to + step
      next if @facet == :age && value.zero?

      counts[(value - from).div(step)] += count
    end
    groups = from.step(to, step).each_with_index.map do |start, index|
      first = @facet == :age && start.zero? ? 1 : start
      ["#{first} - #{start + step - 1}", counts[index]]
    end
    groups.unshift(['Under 1 year', rows.fetch(0, 0)]) if @facet == :age
    groups
  end

  def buckets
    return unless options[:as] == :integer
    return [0, 135, 5] if @facet == :age
    return [1800, 2000, 10] if @facet == :year_immigrated || @facet.to_s.match?(/(?:\A|_)year(?:_|\z)/)

    nil
  end
end
