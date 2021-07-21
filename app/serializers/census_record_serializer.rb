class CensusRecordSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :year, :profession, :race, :sex, :age
end
