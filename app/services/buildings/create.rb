module Buildings
  module Create
    def self.run(params, user)
      building = Building.new params
      building.created_by = user
      building.save && BuildAddressHistory.new(building).perform
      building
    end
  end
end
