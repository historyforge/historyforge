# frozen_string_literal: true

# Base class for census form configuration. Provides a DSL for describing census forms using "divider" and "input"
# commands. Implemented as singleton with each census year existing as a subclass.
class CensusFormFieldConfig
  class_attribute :inputs, :fields, :comments

  def self.input(field, **options)
    self.fields ||= []
    self.inputs ||= {}
    fields << field
    options[:inline_label] = 'Yes' if options[:as] == :boolean
    if %i[radio_buttons radio_buttons_other select].include?(options[:as])
      collection = census_record_class.try(:"#{field}_choices")
      options[:collection] ||= collection if collection
    end
    inputs[field] = options
  end

  def self.divider(title, **options)
    self.fields ||= []
    self.inputs ||= {}
    fields << title
    inputs[title] = options.merge({ as: :divider, label: title })
  end

  def self.options_for(field)
    inputs[field]
  rescue StandardError => error
    Rails.logger.error "*** Field Config Missing for #{field}! ***"
    raise error
  end

  def self.facets
    inputs.select { |_key, value| value[:as] != :divider && !value.key?(:facet) }.keys
  end

  def self.census_record_class
    to_s.sub(/FormFields/, 'Record').safe_constantize
  end

  def self.scope_fields_for(year)
    with_options edit_only: true do
      divider 'Census Scope'
      input :page_number, as: :integer, min: 0, max: 10_000, facet: false
      input :page_side, as: :select, facet: false if year > 1870
      input :line_number, as: :integer, min: 0, max: 100, facet: false
      input :county, hint: false, facet: false
      input :city, input_html: { id: 'city' }, hint: false, facet: false
      input :post_office, facet: false if [1860, 1870].include?(year)
      input :ward, as: :integer, min: 0, max: 10_000, facet: false if year > 1880 && year < 1950
      input :enum_dist, facet: false if year >= 1880
      if year == 1950
        input :institution_name, as: :string, facet: false
        input :institution_type, as: :string, facet: false
      end
      input :locality_id, as: :select, collection: Locality.all, required: true, facet: false
      input :street_house_number, facet: false
      input :street_prefix, as: :select, collection: %w[N S E W], facet: false
      input :street_name, input_html: { id: 'street_name' }, facet: false
      input :street_suffix, as: :select, input_html: { id: 'street_suffix' }, facet: false
      input :apartment_number, facet: false
      input :building_id,
            as: :select,
            collection: [],
            input_html: { id: 'building_id' },
            facet: false
      input :ensure_building, as: :boolean, hint: false, facet: false if Setting.can_add_buildings?(year)
      input :dwelling_number, facet: false if year < 1940
      input :family_id, facet: false
      if year < 1870
        input :institution_name, as: :string, facet: false
        input :institution_type, as: :string, facet: false
      elsif year < 1950
        input :institution, as: :string, facet: false
      end
    end
  end

  def self.name_fields
    divider 'Name'
    input :last_name, facet: false
    input :first_name, facet: false
    input :middle_name, facet: false
    input :name_prefix, facet: false
    input :name_suffix, facet: false
  end

  def self.pre_1870_name_fields
    divider 'Name'
    input :first_name, facet: false
    input :middle_name, facet: false
    input :last_name, facet: false
    input :name_prefix, facet: false
    input :name_suffix, facet: false
  end

  def self.additional_fields
    divider 'Additional'
    input :notes, as: :text, facet: false
    input :person_id,
          facet: false,
          if: ->(form) { form.object.persisted? && form.template.can?(:review, form.object) },
          label: 'Person ID'
  end
end
