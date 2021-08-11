module CensusNameFields
  extend ActiveSupport::Concern
  included do
    divider 'Name'
    input :last_name
    input :first_name
    input :middle_name
    input :name_prefix
    input :name_suffix
  end
end
