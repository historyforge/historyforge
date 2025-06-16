# frozen_string_literal: true

MODELS = [Photograph, Audio, Document]

namespace :update_models do
  task generate_autogen: :environment do
    MODELS.each do |model|
      null_logger = Logger.new(IO::NULL)
      original_logger = ActiveRecord::Base.logger

      ActiveRecord::Base.logger = null_logger
      PaperTrail.request(enabled: false) do # Disable PaperTrail for this task
        model.find_each do |record|
          record.save! if record.data_uri.present?
          puts "✅ Processed #{model.name} ##{record.id}"
        rescue StandardError => e
          puts "❌ Failed for #{model.name} ##{record.id}: #{e.class} - #{e.message}"
        end
      end
      ActiveRecord::Base.logger = original_logger
    end
  end
end
