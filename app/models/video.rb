# frozen_string_literal: true

class Video < ApplicationRecord
  include Media
  include MediaDateBehavior

  validates :file, attached: true, content_type: %w[video/mp4]

  has_one_attached :thumbnail

  after_commit :process, on: :create

  def processed?
    processed_at.present?
  end

  def thumbnail_processed?
    thumbnail_processed_at.present?
  end

  def process
    AudioProcessingJob.perform_later(self.id)
  end
end
