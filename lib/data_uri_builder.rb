# frozen_string_literal: true

require 'open-uri'
require 'base64'

module DataUriBuilder
  def self.encode_active_storage_file(file)
    return nil unless file.attached?

    base64 = Base64.strict_encode64(file.download)
    "data:#{file.content_type};base64,#{base64}"
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
