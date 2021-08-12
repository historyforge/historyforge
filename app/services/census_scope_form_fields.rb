# frozen_string_literal: true

module CensusScopeFormFields
  extend ActiveSupport::Concern

  included do
    with_options edit_only: true do
      divider 'Census Scope'
      input :page_number, as: :integer, min: 0, max: 10_000
      input :page_side, as: :select, collection: %w[A B]
      input :line_number, as: :integer, min: 0, max: 100
      input :county
      input :city, input_html: { id: 'city' }
      input :ward, as: :integer, min: 0, max: 10_000, if: ->(form) { form.object.year > 1880 }
      input :enum_dist, as: :integer, min: 0, max: 10_000
      input :street_house_number
      input :street_prefix, as: :select, collection: %w[N S E W]
      input :street_name, input_html: { id: 'street_name' }
      input :street_suffix, as: :select, input_html: { id: 'street_suffix' }
      input :apartment_number
      input :building_id,
            as: :select,
            collection: ->(form) { BuildingsOnStreet.new(form.object).perform },
            input_html: { id: 'building_id' }
      input :ensure_building, as: :boolean,
            if: ->(form) { form.object.building_id.blank? && Setting.can_add_buildings?(form.object.year) }
      input :locality_id, as: :select, collection: Locality.order(:position), required: true
      input :dwelling_number, if: ->(form) { form.object.year < 1940 }
      input :family_id
    end
  end
end
