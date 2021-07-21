module Cms
  class MenuPresenter
    attr_accessor :model, :current_user, :template, :theme
    def initialize(model, current_user, template)
      @model, @current_user, @template = model, current_user, template
      @theme = model.theme_callback || :menu_list
    end

    def items
      @items || begin
        @items = model.items.map { |item|
          item.theme_callback ||= :menu_list_item
          item.active_callback ||= :current_page?
          item
        }
        @items = @items.select &:enabled?
        @items = @items.select { |item|
          item.access_callback.present? ? template.public_send(item.access_callback) : true
        }
        @items = Cms::MenuItem.arrange_nodes(@items)
      end
    end

    def to_html
      template.public_send(theme, model, items)
    end
  end
end
