# frozen_string_literal: true

module CensusNameFields
  extend ActiveSupport::Concern
  included do
    divider 'Name'
    input :last_name, facet: false
    input :first_name, facet: false
    input :middle_name, facet: false
    input :name_prefix, facet: false
    input :name_suffix, facet: false
  end
end
