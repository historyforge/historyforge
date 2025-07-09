# frozen_string_literal: true

module NameCleaning
  refine String do
    def clean
      tr('.', ' ').tr('’', "'").squish
    end
  end
end
