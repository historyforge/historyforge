# frozen_string_literal: true

class CodeAsiaticIndianRace < ActiveRecord::Migration[7.2]
  def up
    replace_race('Asiatic Indian', 'AsiInd')
  end

  def down
    replace_race('AsiInd', 'Asiatic Indian')
  end

  private

  def replace_race(from, to)
    %w[census_1950_records people].each do |table|
      execute "UPDATE #{table} SET race = #{connection.quote(to)} WHERE race = #{connection.quote(from)}"
    end
  end
end
