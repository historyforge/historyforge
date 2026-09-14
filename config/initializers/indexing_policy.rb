# frozen_string_literal: true

require Rails.root.join('lib/middleware/indexing_policy')

Rails.application.config.middleware.insert_before 0, IndexingPolicy
