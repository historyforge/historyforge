# frozen_string_literal: true

module NameCleaning
  refine String do
    def clean
      gsub(/\./, ' ').squish
    end
  end
end
