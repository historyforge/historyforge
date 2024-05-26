# frozen_string_literal: true

class Video < ApplicationRecord
  include Media
  include MediaDateBehavior

  validates :file, attached: true, content_type: %w[video/mp4]

  has_one_attached :thumbnail

  def processed?
    processed_at.present?
  end

  def thumbnail_processed?
    thumbnail_processed_at.present?
  end

  def process
    VideoProcessingJob.perform_later(id)
  end
end
