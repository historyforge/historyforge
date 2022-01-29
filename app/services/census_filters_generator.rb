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
      AttributeBuilder.collection json, field, klass: klass, collection: collection
      return
    end

    case options[:as]
    when :number, :integer
      AttributeBuilder.number json, field, klass: klass
    when :boolean
      AttributeBuilder.boolean json, field, klass: klass
    when :radio_buttons
      AttributeBuilder.enumeration json, klass, field
    else
      AttributeBuilder.text json, field, klass: klass
    end
  end

  def coded_collection(field, options)
    options[:collection].map do |item|
      code = item.downcase == item ? item.capitalize : item
      code = code.gsub('_', ' ')
      label = Translator.option field, item
      code == label ? label : ["#{code} - #{Translator.option(field, item)}", code]
    end
  end

  def output_header_fields
    AttributeBuilder.collection json, :locality_id, klass:, collection: Locality.select_options
    AttributeBuilder.text(json, :name, klass:)
    AttributeBuilder.text   json, :first_name, klass: klass
    AttributeBuilder.text   json, :middle_name, klass: klass
    AttributeBuilder.text   json, :last_name, klass:
    json.census_scope do
      json.label 'Census Schedule'
      json.sortable 'census_scope'
    end
    AttributeBuilder.number json, :page_number, klass: klass
    AttributeBuilder.enumeration json, klass, :page_side
    AttributeBuilder.number json, :line_number, sortable: false, klass: klass
    AttributeBuilder.text   json, :county, klass: klass
    AttributeBuilder.text   json, :city, klass: klass
    AttributeBuilder.number json, :ward, klass: klass
    AttributeBuilder.number json, :enum_dist, klass: klass
    AttributeBuilder.text   json, :street_address, klass:
    AttributeBuilder.text   json, :dwelling_number, klass: klass unless klass == Census1940Record
    AttributeBuilder.text   json, :family_id, klass: klass
  end

  def output_footer_fields
    AttributeBuilder.boolean json, :foreign_born, klass: klass
    AttributeBuilder.text json, :notes, klass: klass
  end
end
