# frozen_string_literal: true

class VideoProcessingJob < ApplicationJob
  def perform(video_id)
    @video = Video.find video_id

    video.processed? || process!
  end

  private

  attr_reader :video

  def process!
    return unless movie.valid?

    attach_file
    attach_thumbnail
    update_attributes
    clean_up
  end

  def attach_file
    video.file.attach(
      io: File.open(target_filename),
      filename:,
      content_type: 'video/mp4'
    )
  end

  def attach_thumbnail
    FFMPEG::Movie.new(target_filename).screenshot(thumbnail_target_filename, seek_time: 5)
    video.thumbnail.attach(
      io: File.open(thumbnail_target_filename),
      filename: thumbnail_filename,
      content_type: 'image/jpeg'
    )
  end

  def update_attributes
    video.update!(
      duration: movie.duration.to_i,
      file_size: movie.size / 1000,
      width: movie.width,
      height: movie.height,
      thumbnail_processed_at: Time.current,
      processed_at: Time.current
    )
  end

  def clean_up
    FileUtils.rm_f target_filename
    FileUtils.rm_f thumbnail_target_filename
  end

  def source_filename
    ActiveStorage::Blob.service.send(:path_for, video.file.key)
  end

  def target_filename
    Rails.root.join('tmp', filename).to_s
  end

  def filename
    "video-#{video.id}.mp4"
  end

  def thumbnail_target_filename
    Rails.root.join('tmp', thumbnail_filename).to_s
  end

  def thumbnail_filename
    "video-#{video.id}-preview.jpg"
  end

  def movie
    @movie ||= FFMPEG::Movie.new(source_filename).transcode(target_filename, FFMPEG_OPTIONS)
  end

  FFMPEG_OPTIONS = %w[-movflags faststart -pix_fmt yuv420p -vf scale=-2:600 -vsync 1 -vcodec libx264 -r 29.970
                      -threads 0 -b:v: 1024k -bufsize 1216k -maxrate 1280k -preset medium -profile:v main -tune film
                      -g 60 -x264opts no-scenecut -acodec aac -b:a 192k -ac 2 -ar 44100 -af
                      aresample=async=1:min_hard_comp=0.100000:first_pts=0 -f mp4].freeze
end
