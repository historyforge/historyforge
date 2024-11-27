# frozen_string_literal: true

# Converts the census form into a format consumable by the "advanced search" filter button
# using JBuilder object passed in as json
class CensusFiltersGenerator
  def self.generate(json, config)
    new(json, config).render
  end

  def initialize(json, config)
    @json = json
    @config = config
    @klass = config.census_record_class
    @card = nil
  end

  def render
    output_header_fields
    config.fields.each { |field| add_field field, config.options_for(field) }
    output_footer_fields
    json
  end

  private

  attr_reader :json, :card, :klass, :config

  def add_field(field, options)
    return if options[:edit_only]

    @card = options[:label] and return if options[:as] == :divider
    return if card == 'Name' || card == 'Census Scope'

    if options[:collection]
      collection = options[:coded] ? coded_collection(field, options) : options[:collection]
      AttributeBuilder.collection(json, field, klass:, collection:)
      return
    end

    case options[:as]
    when :number, :integer
      AttributeBuilder.number json, field, klass:
    when :boolean
      AttributeBuilder.boolean json, field, klass:
    when :radio_buttons
      AttributeBuilder.enumeration json, klass, field
    else
      AttributeBuilder.text json, field, klass:
    end
  end

  def coded_collection(field, options)
    options[:collection].map do |item|
      code = item.downcase == item ? item.capitalize : item
      translated_code = field == :race && @klass.respond_to?(:translate_race_code) ? @klass.translate_race_code(code) : code
      attribute = options[:coded].is_a?(Symbol) ? options[:coded] : field
      label = Translator.option attribute, item
      translated_code == label ? label : ["#{translated_code.gsub('_', ' ')} - #{label}", code]
    end
  end

  def output_header_fields
    AttributeBuilder.collection(json, 
                                :locality_id, 
                                klass:,
                                choices: Locality.all.map { |locality| [locality.name, locality.id] })
    AttributeBuilder.text(json, :name, klass:)
    AttributeBuilder.text(json, :first_name, klass:)
    AttributeBuilder.text(json, :middle_name, klass:)
    AttributeBuilder.text(json, :last_name, klass:)
    json.census_scope do
      json.label 'Census Schedule'
      json.sortable 'census_scope'
    end
    AttributeBuilder.number(json, :page_number, klass:)
    AttributeBuilder.enumeration(json, klass, :page_side) if klass.year >= 1880
    AttributeBuilder.number(json, :line_number, sortable: false, klass:)
    AttributeBuilder.text(json, :county, klass:)
    AttributeBuilder.text(json, :city, klass:)
    if klass.year >= 1880
      AttributeBuilder.number(json, :ward, klass:)
      AttributeBuilder.number(json, :enum_dist, klass:)
    end
    if klass.year == 1950 || klass.year < 1870
      AttributeBuilder.text(json, :institution_name, klass:)
      AttributeBuilder.text(json, :institution_type, klass:)
    end
    AttributeBuilder.text(json, :institution, klass:) if klass.year >= 1870 && klass.year <= 1940
    AttributeBuilder.text(json, :street_address, klass:)
    AttributeBuilder.text(json, :dwelling_number, klass:) unless klass == Census1940Record
    AttributeBuilder.text(json, :family_id, klass:)
  end

  def output_footer_fields
    AttributeBuilder.boolean(json, :foreign_born, klass:)
    AttributeBuilder.text(json, :notes, klass:)
  end
end
