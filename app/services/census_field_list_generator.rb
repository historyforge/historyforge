# frozen_string_literal: true

# Converts the census form into a format consumable by the "advanced search" filter button
# using JBuilder object passed in as json
class CensusFieldListGenerator
  def self.generate(config)
    new(config).render
  end

  def initialize(config)
    @config = config
    @klass = config.census_record_class
    @card = nil
    @fields = []
  end

  def render
    output_header_fields
    config.fields.each { |field| add_field field, config.options_for(field) }
    output_footer_fields
    @fields
  end

  private

  attr_reader :card, :klass, :config

  def add_field(field, options)
    return if options[:edit_only]

    @card = options[:label] and return if options[:as] == :divider
    return if card == 'Name' || card == 'Census Scope'

    @fields << field.to_s
  end

  def output_header_fields
    @fields.concat %w[locality_id name first_name middle_name last_name census_scope page_number]
    @fields << 'page_side' if klass.year >= 1880
    @fields.concat %w[line_number county city]
    @fields << 'ward' unless klass.year <= 1880
    @fields << 'enum_dist' if klass.year >= 1880
    @fields.concat %w[street_address]
    @fields.concat %w[institution_name institution_type] if klass == Census1950Record
    @fields << 'dwelling_number' unless klass == Census1940Record || klass == Census1950Record
    @fields << 'family_id'
  end

  def output_footer_fields
    @fields.concat %w[street_house_number street_prefix street_name street_suffix latitude longitude]
  end
end
