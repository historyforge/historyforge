# frozen_string_literal: true

module Buildings
  module Update
    def self.run(building, params)
      success = building.update(params)
      BuildAddressHistory.new(building).perform
      success
    end
  end
end
