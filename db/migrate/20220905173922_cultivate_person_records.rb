class CultivatePersonRecords < ActiveRecord::Migration[7.0]
  def up
    execute <<~SQL
      DELETE FROM people WHERE id IN(
          SELECT people.id FROM people LEFT OUTER JOIN people_photographs ON people_photographs.person_id=people.id
            LEFT OUTER JOIN census_1880_records ON people.id=census_1880_records.person_id
            LEFT OUTER JOIN census_1900_records ON people.id=census_1900_records.person_id
            LEFT OUTER JOIN census_1910_records ON people.id=census_1910_records.person_id
            LEFT OUTER JOIN census_1920_records ON people.id=census_1920_records.person_id
            LEFT OUTER JOIN census_1930_records ON people.id=census_1930_records.person_id
            LEFT OUTER JOIN census_1940_records ON people.id=census_1940_records.person_id
            LEFT OUTER JOIN census1950_records ON people.id=census1950_records.person_id
            WHERE people_photographs.photograph_id IS NULL AND census_1880_records.id IS NULL AND census_1900_records.id IS NULL
              AND census_1910_records.id IS NULL AND census_1920_records.id IS NULL AND census_1930_records.id IS NULL
              AND census_1940_records.id IS NULL AND census1950_records.id IS NULL
          )
    SQL
  end

  def down
  end
end
