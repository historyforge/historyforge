class CleanOutPhotographMetadataStuff < ActiveRecord::Migration[6.0]
  def up
    remove_column :photographs, :rights_statement_id
    remove_column :photographs, :physical_description
    remove_column :photographs, :physical_format_id
    remove_column :photographs, :physical_type_id
    remove_column :photographs, :title
    remove_column :photographs, :subject
    drop_table :rights_statements
    drop_table :physical_formats_types
    drop_table :physical_formats
    drop_table :physical_types
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
