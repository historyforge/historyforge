class RedoTrigramIndices < ActiveRecord::Migration[7.0]
  def change
    with_options(using: :gist, opclass: { title: :gist_trgm_ops }) do
      CensusYears.each do |year|
        skip_years = [1940, 1950]
        next if skip_years.include?(year) # seems like we forgot an index here

        remove_index :"census_#{year}_records", :searchable_name
      end
      remove_index :person_names, :searchable_name
    end

    with_options(using: :gin, opclass: { title: :gin_trgm_ops }) do
      CensusYears.each do |year|
        add_index :"census_#{year}_records", :searchable_name
      end
      add_index :person_names, :searchable_name
    end
  end
end
