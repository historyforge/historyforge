# frozen_string_literal: true

class DataDictionary
  def self.census_code(field, code)
    instance.lookup_code(field, code)
  end

  def self.label(field, year)
    instance.lookup(:label, field, year)
  end

  def self.hint(field, year)
    instance.lookup(:hint, field, year)
  end

  def self.filter(field, year)
    instance.lookup(:filter, field, year) || instance.lookup(:label, field, year)
  end

  def self.column(field, year)
    instance.lookup(:column, field, year)
  end

  def self.field_from_label(label, year)
    instance.field_from_label(label, year)
  end

  def self.code_from_label(label, field)
    instance.code_from_label(label, field)
  end

  def self.coded_attribute?(field)
    instance.coded_attribute?(field)
  end

  def self.instance
    @instance ||= new
  end

  def initialize
    file = Rails.root.join('config/census-dictionary.json')
    data = JSON.parse(File.read(file))
    @dictionary = ActiveSupport::HashWithIndifferentAccess.new(data)
  end

  def lookup_code(field, item)
    code = item.downcase.gsub(/\W/, '')
    @dictionary[:codes][field][code] || @dictionary[:codes][:defaults][code]
  end

  def lookup(thing, field, year)
    field_config = @dictionary[:fields][field]
    return field.to_s.humanize unless field_config

    (field_config[year.to_s] || {}).reverse_merge(field_config[:defaults])[thing]
  end

  def field_from_label(label, year)
    @dictionary[:fields].each do |key, config|
      return key if config.dig(year.to_s, :label)&.downcase&.strip == label.downcase.strip
      return key if config.dig(:defaults, :label)&.downcase&.strip == label.downcase.strip
    end
    raise ArgumentError("Cannot find #{label} for #{year}")
  end

  def code_from_label(label, field)
    config = @dictionary[:codes][field]
    return unless config

    values = config.reverse_merge(@dictionary[:codes][:default])
    values.each do |key, value|
      return key if value == label
    end

    label
  end

  def coded_attribute?(field)
    @dictionary[:codes][field]
  end
end
