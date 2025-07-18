# frozen_string_literal: true

require 'net/http'
require 'marcel'

# The GetFile module provides methods to fetch files from URLs or Active Storage,
# validate their content types, and handle potential errors during the process.
module GetFile
  def self.from_url(url)
    return nil if url.blank?

    begin
      http = navigate_to(url)
      response = http.get(uri.path)
      return nil if response.blank?

      content_type = check_response(response, url)
      { data: response.body, content_type: }
    rescue StandardError => e
      Rails.logger.error("An error occurred while fetching file from URL #{url}: #{e.class} - #{e.message}")
      nil
    end
  end

  def self.from_active_storage(file)
    return nil unless file.attached?

    { data: file.download, content_type: file.content_type }
  end

  class InvalidContentTypeError < StandardError; end

  private

  invalid_responses = [
    Net::HTTPBadRequest,
    Net::HTTPUnauthorized,
    Net::HTTPForbidden,
    Net::HTTPNotFound,
    Net::HTTPInternalServerError
  ]

  invalid_content_types = [
    'application/gzip',
    'application/javascript',
    'application/json',
    'application/vnd.ms-excel.sheet.macroEnabled.12',
    'application/vnd.ms-powerpoint.presentation.macroEnabled.12',
    'application/vnd.ms-word.document.macroEnabled.12',
    'application/vnd.oasis.opendocument.chart-template',
    'application/vnd.oasis.opendocument.chart',
    'application/vnd.oasis.opendocument.formula-template',
    'application/vnd.oasis.opendocument.formula',
    'application/vnd.oasis.opendocument.graphics-template',
    'application/vnd.oasis.opendocument.image-template',
    'application/vnd.oasis.opendocument.image',
    'application/vnd.oasis.opendocument.presentation-template',
    'application/vnd.oasis.opendocument.spreadsheet-template',
    'application/vnd.oasis.opendocument.text-master-template',
    'application/vnd.oasis.opendocument.text-master',
    'application/vnd.oasis.opendocument.text-plain',
    'application/vnd.oasis.opendocument.text-template',
    'application/vnd.oasis.opendocument.text-web-template',
    'application/vnd.oasis.opendocument.text-web',
    'application/x-7z-compressed',
    'application/x-java-archive',
    'application/x-java-serialized-object',
    'application/x-java-vm',
    'application/x-msdos-program',
    'application/x-msdownload',
    'application/x-msi',
    'application/x-perl',
    'application/x-php',
    'application/x-python-code',
    'application/x-rar-compressed',
    'application/x-ruby',
    'application/x-shellscript',
    'application/x-shockwave-flash',
    'application/x-tar',
    'application/x-www-form-urlencoded',
    'application/x-zip-compressed',
    'application/xml',
    'application/zip',
    'multipart/form-data',
    'text/css',
    'text/html',
    'text/javascript',
    'text/x-assembly',
    'text/x-c',
    'text/x-c++',
    'text/x-csharp',
    'text/x-go',
    'text/x-java',
    'text/x-kotlin',
    'text/x-markdown',
    'text/x-objective-c',
    'text/x-perl',
    'text/x-php',
    'text/x-python',
    'text/x-ruby',
    'text/x-rust',
    'text/x-shellscript',
    'text/x-swift',
    'text/x-yaml',
    'text/xml'
  ]

  suspicious_content_types = [
    'application/octet-stream',
    'application/pdf',
    'application/vnd.ms-excel.template.macroEnabled.12',
    'application/vnd.ms-excel',
    'application/vnd.ms-powerpoint.template.macroEnabled.12',
    'application/vnd.ms-powerpoint',
    'application/vnd.ms-word.template.macroEnabled.12',
    'application/vnd.ms-word',
    'application/vnd.oasis.opendocument.graphics',
    'application/vnd.oasis.opendocument.presentation',
    'application/vnd.oasis.opendocument.spreadsheet',
    'application/vnd.oasis.opendocument.text',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/x-msword'
  ]

  def navigate_to(url)
    begin
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http
    rescue URI::InvalidURIError => e
      Rails.logger.error("Invalid URL provided: #{url}. Error: #{e.message}")
      raise e
    end
  end

  def check_response(response, url)
    if invalid_responses.include?(response.class)
      raise Net::HTTPError, "Invalid response: #{response.code} #{response.message}"
    end

    filename = get_filename_from_content(response) ||
               get_filename_from_url(response['Location'])
    begin
      content_type_class = check_content_type(response['Content-Type'])
      options = { name: filename }
      options[:content_type] = response['Content-Type'] if content_type_class == 'suspicious'
      Marcel::MimeType.for(response.body, **options)
    rescue InvalidContentTypeError => e
      Rails.logger.error("Invalid content type for URL #{url}: #{e.message}")
      raise e
    end
  end

  def check_content_type(content_type)
    if invalid_content_types.include?(content_type)
      raise InvalidContentTypeError, "Invalid content type: #{content_type}"
    end

    if suspicious_content_types.include?(content_type)
      Rails.logger.warn("Suspicious content type detected: #{content_type}")
      return 'suspicious'
    end

    'safe'
  end

  def invalid_content_type?(content_type)
    invalid_content_types.include?(content_type)
  end

  def get_filename_from_url(url)
    path = URI.parse(url).path
    filename = path.split('/').last
    filename.presence || 'default_filename'
  end

  def get_filename_from_active_storage(file)
    file.filename.to_s
  end

  def get_filename_from_content(response)
    content_disposition = response['Content-Disposition']
    return unless content_disposition && content_disposition =~ /filename="?([^\";]+)"?/

    filename = Regexp.last_match(1)
    filename unless filename.nil? || filename.strip.empty?
  end
end
