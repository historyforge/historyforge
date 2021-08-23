class CensusRecordSerializer < ApplicationSerializer
  def serializable_attributes
    %i[id name year profession race sex age]
  end
end
