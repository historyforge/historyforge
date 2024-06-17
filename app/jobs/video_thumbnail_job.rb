# frozen_string_literal: true

class VideoThumbnailJob < ApplicationJob
  def perform(video_id)
    video = Video.find video_id
    process unless video.thumbnail_processed?
  end

  private

  attr_reader :video

  def process
    FFMPEG::Movie.new(source_filename).screenshot(target_filename, seek_time: 5, resolution: '800x450')
    video.thumbnail.attach(
      io: File.open(target_filename),
      filename:,
      content_type: 'image/jpeg'
    )
    video.update(thumbnail_processed_at: Time.current)
    FileUtils.rm_f target_filename
  end

  def source_filename
    ActiveStorage::Blob.service.send(:path_for, video.file.key)
  end

  def target_filename
    Rails.root.join('tmp', filename).to_s
  end

  def filename
    "video-#{video.id}-preview.jpg"
  end
end
