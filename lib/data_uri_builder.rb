# frozen_string_literal: true

require 'open-uri'
require 'base64'

module DataUriBuilder
  def self.encode_active_storage_file(file)
    return nil unless file.attached?
    return nil unless file.blob.persisted?

    begin
    base64 = Base64.strict_encode64(file.download)
      "data:#{file.content_type};base64,#{base64}"
    rescue ActiveStorage::FileNotFoundError => e
      Rails.logger.warn("ActiveStorage file not found: #{e.message}")
      nil
    rescue StandardError => e
      Rails.logger.error("Failed to encode ActiveStorage file: #{e.message}")
      nil
    end
  end

  def self.encode_active_storage_file_from_attachment(file_attachment)
    return nil unless file_attachment.attached?

    blob = file_attachment.blob

    begin
      # Try to get the data from the blob directly, whether persisted or not
      file_data = if blob.persisted? && blob.service.exist?(blob.key)
                    # File is persisted and exists in storage
                    file_attachment.download
                  elsif blob.io.respond_to?(:read)
                    # File is in memory or temporary storage
                    blob.io.read
                  elsif blob.io.respond_to?(:path) && File.exist?(blob.io.path)
                    # File is in temporary file system
                    File.binread(blob.io.path)
                  else
                    # Fallback: try to open the file from the blob's io
                    blob.io.read
                  end

      base64 = Base64.strict_encode64(file_data)
      "data:#{blob.content_type};base64,#{base64}"
    rescue StandardError => e
      Rails.logger.error("Failed to encode ActiveStorage file from attachment: #{e.message}")
      nil
    end
  end

  def self.encode_url_file(url)
    file_data = URI.open(url, &:read)
    content_type = begin
      URI.open(url).content_type
    rescue StandardError
      'application/octet-stream'
    end
    base64 = Base64.strict_encode64(file_data)
    "data:#{content_type};base64,#{base64}"
  rescue OpenURI::HTTPError, SocketError => e
    Rails.logger.error("Base64 encode failed for URL #{url}: #{e.message}")
    nil
  end

end
