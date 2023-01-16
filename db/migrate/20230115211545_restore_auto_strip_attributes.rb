class RestoreAutoStripAttributes < ActiveRecord::Migration[7.0]
  def up
    Building.where(city: '').update_all(city: AppConfig[:city])
    Building.where(state: '').update_all(state: AppConfig[:state])
    models = [Building].concat CensusYears.map { |year| "Census#{year}Record".safe_constantize }
    models.each do |model|
      model.text_columns.each do |attribute|
        model.where(attribute => '').update_all(attribute => nil)
      end
    end
  end

  def down; end
end
