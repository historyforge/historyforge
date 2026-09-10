# frozen_string_literal: true

ActiveSupport::Inflector.inflections(:en) do |inflect|
  %w[us dpw wpa nya ccc glf rr md ny nys po pob].each do |letters|
    inflect.acronym letters.upcase
  end
end
