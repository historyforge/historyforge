class AlsoMigrateBNegOnPersonTable < ActiveRecord::Migration[7.0]
  def change
    [
      %w[Neg B], %w[M Mu], %w[Jap Jp]
    ].each do |(source, target)|
      Person.where(race: source).each do |person|
        person.race = target
        person.save
      end
    end
  end
end
