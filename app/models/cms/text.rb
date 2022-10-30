# == Schema Information
#
# Table name: cms_page_widgets
#
#  id          :bigint           not null, primary key
#  cms_page_id :bigint
#  type        :string
#  data        :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_cms_page_widgets_on_cms_page_id  (cms_page_id)
#

# frozen_string_literal: true

module Cms
  class Text < Cms::PageWidget
    has_rich_text :html

    def cached_html
      html.to_s
    end
  end
end
