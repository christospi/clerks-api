require 'net/http'

module Downloader
  def self.download(url)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)

    raise "Unable to download file from #{url}" unless response.is_a?(Net::HTTPSuccess)

    Tempfile.new.tap do |file|
      file.binmode
      file.write(response.body)
      file.rewind
    end
  rescue StandardError => e
    Rails.logger.error("Failed to download file from #{url}: #{e}")
    nil
  end
end
