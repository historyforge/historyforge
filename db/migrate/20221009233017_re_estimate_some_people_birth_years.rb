class ReEstimateSomePeopleBirthYears < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        Person.where('birth_year < 1000').each &:save
        Person.where(birth_year: nil).each &:save
      end
    end
  end
end
