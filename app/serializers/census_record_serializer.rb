class CensusRecordSerializer < ApplicationSerializer
  def serializable_attributes
    %i[id name year occupation race sex age relation_to_head]
  end
end
