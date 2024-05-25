# frozen_string_literal: true

class Audio < ApplicationRecord
  include Media
  include MediaDateBehavior

  validates :file, attached: true, content_type: %w[audio/mpeg]

  after_commit :process, on: :create

  def processed?
    processed_at.present?
  end

  def process
    AudioProcessingJob.perform_later(self.id)
  end
end
