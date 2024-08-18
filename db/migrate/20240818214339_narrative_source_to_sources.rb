class NarrativeSourceToSources < ActiveRecord::Migration[7.0]
  include ActionView::Helpers::TextHelper
  def up
    Narrative.find_each do |narrative|
      narrative.sources = simple_format(narrative.source)
      narrative.save
    end
  end

  def down; end
end
