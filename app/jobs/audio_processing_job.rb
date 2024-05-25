# frozen_string_literal: true

class AudioProcessingJob < ApplicationJob
  def perform(audio_id)
    @audio = Audio.find audio_id
    audio.processed? || process!
  end

  private

  attr_reader :audio

  def process!
    return unless movie.valid?

    audio.file.attach(
      io: File.open(target_filename),
      filename:,
      content_type: 'audio/mpeg'
    )
    audio.update!(
      duration: movie.duration.to_i,
      file_size: movie.size / 1000,
      processed_at: Time.current
    )
    FileUtils.rm_f target_filename
  end

  def movie
    @movie ||= FFMPEG::Movie.new(source_filename).transcode(target_filename)
  end

  def source_filename
    ActiveStorage::Blob.service.send(:path_for, audio.file.key)
  end

  def target_filename
    Rails.root.join('tmp', filename).to_s
  end

  def filename
    "audio-#{audio.id}.mp3"
  end
end
