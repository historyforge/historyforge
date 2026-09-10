# frozen_string_literal: true

class ReplaceGoogleVolunteerFormLinks < ActiveRecord::Migration[8.0]
  FORM_URL = %r{https?://docs\.google\.com/forms/(?:u/\d+/)?d/e/1FAIpQLScyKwGqJzcqZSLwEL73edff9K37XRyGdx9FOSKWtmLk_6fIvw/viewform(?:\?[^\s"'<>]*)?}.freeze

  class Page < ActiveRecord::Base
    self.table_name = 'cms_pages'
    self.inheritance_column = :_type_disabled
  end

  class Widget < ActiveRecord::Base
    self.table_name = 'cms_page_widgets'
    self.inheritance_column = :_type_disabled
  end

  class RichText < ActiveRecord::Base
    self.table_name = 'action_text_rich_texts'
  end

  def up
    [Page, Widget].each do |model|
      model.find_each do |record|
        updated = replace_links(record.data)
        record.update_columns(data: updated, updated_at: Time.current) if updated != record.data
      end
    end
    RichText.where(record_type: ['Cms::PageWidget', 'Cms::Text'], record_id: Widget.select(:id)).find_each do |record|
      updated = replace_links(record.body)
      record.update_columns(body: updated, updated_at: Time.current) if updated != record.body
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Cannot distinguish replaced links from existing native volunteer links.'
  end

  private

  def replace_links(value)
    case value
    when String then value.gsub(FORM_URL, '/volunteer_applications/new')
    when Hash then value.transform_values { |item| replace_links(item) }
    when Array then value.map { |item| replace_links(item) }
    else value
    end
  end
end
