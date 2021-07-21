class ArchitectSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name
end
