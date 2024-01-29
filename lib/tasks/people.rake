# frozen_string_literal: true

namespace :people do
  task reindex: :environment do
    CensusYears.each do |year|
      PgSearch::Multisearch.rebuild("Census#{year}Record".constantize)
    end
  end
end
