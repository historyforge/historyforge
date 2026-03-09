# frozen_string_literal: true

# This module provides a way to generate/store a checksum for a file or URL.
# It uses SHA256 to compute the checksum and stores it in the `file_checksum` attribute.
# The checksum is generated before saving the record if the file or URL has changed.
# This can be useful for verifying file integrity or detecting changes.
#
# Example usage:
# class Media < ApplicationRecord
#   include FileChecksum
# end
#
# The `checksum` attribute should be defined in the model's database schema.
# Ensure that the `checksum` column is added to the model's database table.
module FileChecksum
  extend ActiveSupport::Concern

  included do
    before_save :generate_checksum, if: :should_generate_checksum?
  end

  def should_generate_checksum?
    file_changed = if self[:checksum].nil?
                     return true
                   else
                     self[:checksum] != checksum
                   end
    url_changed = respond_to?(:will_save_change_to_url?) ? will_save_change_to_url? : false
    file_changed || url_changed
  end

  def generate_checksum
    self.file_checksum = if respond_to?(:file) && file&.attached?
                           file&.blob&.checksum
                         elsif respond_to?(:url) && url.present?
                           begin
                             result = GetFile.from_url(url)
                             Digest::SHA256.hexdigest(result[:data]) unless result.blank? || result[:data].blank?
                           rescue Net::OpenTimeout, Net::ReadTimeout, Net::ConnectionError, Net::HTTPError => e
                             # Handle the error, e.g. log it and return a default value
                             Rails.logger.error("Error fetching URL: #{e.message}")
                             nil
                           end
                         end
  end
end
