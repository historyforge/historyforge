class MigrateRaceValues < ActiveRecord::Migration[7.0]
  def up
    Census1930Record.where(race: 'Neg').each do |rec|
      rec.race = 'B'
      rec.save
    end
    Census1940Record.where(race: 'Neg').each do |rec|
      rec.race = 'B'
      rec.save
    end
    Census1950Record.where(race: 'Neg').each do |rec|
      rec.race = 'B'
      rec.save
    end
    Census1950Record.where(race: 'Chi').each do |rec|
      rec.race = 'Ch'
      rec.save
    end
    Census1950Record.where(race: 'Ind').each do |rec|
      rec.race = 'In'
      rec.save
    end
    Census1950Record.where(race: 'Jap').each do |rec|
      rec.race = 'Jp'
      rec.save
    end
  end

  def down
    # no going back!
  end
end
