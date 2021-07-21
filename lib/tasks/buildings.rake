namespace :buildings do
  task address: :environment do
    Building.find_each do |building|
      # create an address record with the building's address
      # look up the census records for this building, create an address record for any mavericks

      Address.from(building)

      building.with_residents.residents.each do |resident|
        Address.from(resident)
      end
    end
  end
end
