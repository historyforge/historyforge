class RepairNamesAgain < ActiveRecord::Migration[6.0]
  def up
    [1900, 1910, 1920, 1930, 1940].each do |year|
      "Census#{year}Record".constantize.find_each do |row|
        old_last_name = row.versions.select { |v| v.changeset['last_name'] }.reverse.first.changeset['last_name'][0] rescue nil
        next unless old_last_name
        next if row.last_name == old_last_name

        row.last_name = old_last_name
        row.save
      end
    end
  end

  def down
  end
end
