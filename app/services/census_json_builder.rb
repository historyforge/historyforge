# frozen_string_literal: true

# Converts the census form into a format consumable by the "advanced search" filter button
# using JBuilder object passed in as json

class CensusJsonBuilder
  def initialize(json, klass)
    @json = json
    @klass = klass
    @card = nil
    output_common_fields
  end

  attr_accessor :json, :card, :klass

  def start_card(card)
    @card = card[:label]
  end

  def add_field(field, config)
    return if config[:edit_only]
    return if card == 'Name' || card == 'Census Scope'

    if config[:collection]
      collection = if config[:coded]
                     config[:collection].map do |item|
                       code = item.downcase == item ? item.capitalize : item
                       code = code.gsub('_', ' ')
                       label = translated_option item, field
                       code == label ? label : ["#{code} - #{translated_option(item, field)}", code]
                     end
                   else
                     config[:collection]
                   end
      AttributeBuilder.collection json, field, klass: klass, collection: collection
      return
    end

    case config[:as]
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

  def output_common_fields
    AttributeBuilder.collection json, :locality_id, klass: klass, collection: Locality.select_options
    AttributeBuilder.text(json, :name, klass: klass)
    AttributeBuilder.text   json, :first_name, klass: klass
    AttributeBuilder.text   json, :middle_name, klass: klass
    AttributeBuilder.text   json, :last_name, klass: klass
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
    AttributeBuilder.text   json, :street_address, klass: klass
    AttributeBuilder.text   json, :dwelling_number, klass: klass unless klass == Census1940Record
    AttributeBuilder.text   json, :family_id, klass: klass

    AttributeBuilder.boolean json, :foreign_born, klass: klass
    AttributeBuilder.text json, :notes, klass: klass
  end
  def to_html
    json
  end

  private

  def translated_option(item, field)
    Translator.option field, item
  end
end
