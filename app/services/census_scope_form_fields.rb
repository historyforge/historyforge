# frozen_string_literal: true

module CensusScopeFormFields
  extend ActiveSupport::Concern

  included do
    with_options edit_only: true do
      divider 'Census Scope'
      input :page_number, as: :integer, min: 0, max: 10_000, facet: false
      input :page_side, as: :select, facet: false
      input :line_number, as: :integer, min: 0, max: 100, facet: false
      input :county, hint: false, facet: false
      input :city, input_html: { id: 'city' }, hint: false, facet: false
      input :ward, as: :integer, min: 0, max: 10_000, if: ->(form) { form.object.year > 1880 }, facet: false
      input :enum_dist, as: :integer, min: 0, max: 10_000, facet: false
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
      input :ensure_building,
            as: :boolean,
            hint: false,
            facet: false,
            if: ->(form) { form.object.building_id.blank? && Setting.can_add_buildings?(form.object.year) }
      input :locality_id, as: :select, collection: Locality.order(:position), required: true, facet: false
      input :dwelling_number, if: ->(form) { form.object.year < 1940 }, facet: false
      input :family_id, facet: false
    end
  end
end
