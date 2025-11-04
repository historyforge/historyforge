# frozen_string_literal: true

namespace :update_models do
  desc 'Update models with autogen fields'
  task generate_autogen: :environment do
    # Ensure all models are loaded
    Rails.application.eager_load!

    # Define the modules you want to detect
    target_modules = [DataUri, FileChecksum]

    # Find all models that include at least one of the target modules
    models = ApplicationRecord.descendants.select do |model|
      target_modules.any? { |mod| model.included_modules.include?(mod) }
    end

    models.each do |model|
      puts "Updating #{model} autogen fields..."
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
