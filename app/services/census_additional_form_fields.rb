# frozen_string_literal: true

module CensusAdditionalFormFields
  extend ActiveSupport::Concern

  included do
    divider 'Additional'
    input :notes, as: :text, facet: false
    input :person_id,
          facet: false,
          if: ->(form) { form.object.persisted? && form.template.can?(:review, form.object) },
          label: 'Person ID',
          hint: 'Use this to link this census record to a person record manually. Clearing out this field will detach any existing person link.'
  end
end
