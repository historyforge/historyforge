# frozen_string_literal: true

# When filling in the census form, the text fields that accept a proper string - such as names and relation to head -
# have an autocomplete feature that offers choices based on what has been entered that year for that attribute.
class AttributeAutocomplete
  def initialize(attribute:, term:, year:)
    @attribute = attribute
    @term = term
    @year = year
    @resource_class = "Census#{year}Record".safe_constantize
  end

  attr_reader :attribute, :term, :year, :resource_class

  def perform
    results = if %w[street_name street_house_number].include?(attribute)
                search_street
              elsif attribute == 'street_address'
                search_address
              elsif %w[first_name middle_name last_name].include?(attribute)
                search_name
              else
                search_term || search_attribute
              end
    results.compact.map(&:strip).uniq
  end

  private

  def search_attribute
    resource_class.ransack("#{attribute}_start": term).result.distinct.limit(15).pluck(attribute)
  rescue ActiveRecord::StatementInvalid
    []
  end

  def search_term
    vocab = Vocabulary.controlled_attribute_for year, attribute

    return false unless vocab

    vocab.terms.ransack(name_start: term).result.distinct.limit(15).pluck('name')
  end

  def search_name
    Person.ransack("#{attribute}_start": term).result.distinct.limit(15).pluck(attribute)
  end

  def search_address
    Address.ransack(street_address_cont: term).result.distinct.limit(15).map(&:address)
  end

  def search_street
    building_attribute = attribute.sub(/^street_/, '')
    Address.ransack("#{building_attribute}_start": term).result.distinct.limit(15).pluck(building_attribute)
  end
end
