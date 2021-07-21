class AddUrlToDocument < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :url, :string, after: :name

    reversible do |dir|
      dir.up do
        Building.find_each do |row|
          next if row.description =~ /\W/ && row.annotations =~ /\W/

          fix_it(row, row.paper_trail.previous_version)
        end
      end
    end
  end

  def fix_it(row, version)
    return if version.blank?

    if version.description =~ /\W/ || version.annotations =~ /\W/
      row.description = version.description
      row.annotations = version.annotations
      row.save
    else
      fix_it(row, version.paper_trail.previous_version)
    end
  end
end
