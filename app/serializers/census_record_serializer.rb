# frozen_string_literal: true

class CensusRecordSerializer < ApplicationSerializer
  def serializable_attributes
    attributes = %i[id name year occupation race sex age]
    attributes << :relation_to_head if object.respond_to?(:relation_to_head)
    attributes
  end
end
