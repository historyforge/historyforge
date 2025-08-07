# frozen_string_literal: true

# This module provides a way to generate a data URI for a file or URL.
# It encodes the file content or the content fetched from a URL into a Base64 string
# and formats it as a data URI. This can be useful for embedding files directly in HTML
# or other contexts where a data URI is needed.
#
# Example usage:
# class Media < ApplicationRecord
#   include DataUri
# end
#
# The `data_uri` attribute should be defined in the model's database schema.
# Ensure that the `data_uri` column is added to the model's database table.
require_relative '../../../lib/data_uri_builder'
module DataUri
  extend ActiveSupport::Concern

  included do
    before_commit :generate_data_uri, on: [:create, :update], if: :should_generate_data_uri?
  end

  def should_generate_data_uri?
    file_changed = if self[:checksum].nil?
                     return true
                   else
                     self[:checksum] != checksum
                   end
    url_changed = respond_to?(:will_save_change_to_url?) ? will_save_change_to_url? : false
    file_changed || url_changed
  end

  def previous_checksum
    @previous_checksum ||= self[:file_checksum]
  end

  def current_file_checksum
    file.attachment&.blob&.checksum
  end

  def generate_data_uri
    return unless file.attached? || (respond_to?(:url) && url.present?)

    data_uri = if respond_to?(:file) && file&.attached?
                 DataUriBuilder.encode_active_storage_file_from_attachment(file)
               elsif respond_to?(:url) && url.present?
                 DataUriBuilder.encode_url_file(url)
               end

    if data_uri
      update_column(:data_uri, data_uri)
    else
      Rails.logger.warn("Failed to generate data URI for #{self.class.name} ID: #{id}")
    end
  end
end
