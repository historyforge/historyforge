namespace :people do
  task connect: :environment do
    CensusYears.each do |year|
      CensusRecord.for_year(year).ids.each do |id|
        MatchCensusToPersonRecordJob.perform_later(year, id)
      end
    end
  end
end
