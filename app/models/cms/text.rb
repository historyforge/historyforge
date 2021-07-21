module Cms
  class Text < Cms::PageWidget
    has_rich_text :html

    def cached_html
      html.to_s
    end
  end
end
