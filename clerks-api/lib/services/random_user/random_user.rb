require 'net/http'

module RandomUser
  BASE_URL = 'https://randomuser.me/api/'.freeze
  DEFAULT_FIELDS = %w[name email phone picture registered].freeze
  # Currently we only support the above fields; we can add more if needed.
  ALLOWED_FIELDS = DEFAULT_FIELDS
  DEFAULT_SIZE = 1
  BATCH_SIZE = 1000

  extend self

  # Fetches a list of random users from the RandomUser API.
  #
  # The method sends a GET request to the RandomUser API and retrieves user data.
  # By default, it fetches 1 user with the name, email, phone, picture, and
  # registration date fields.
  #
  # For more info, see: https://randomuser.me/documentation.
  #
  # @option options [Array<String>] :fields The fields to include in the response.
  #   Must be a subset of ALLOWED_FIELDS (default: DEFAULT_FIELDS).
  # @option options [Integer] :size The number of users to fetch (default: DEFAULT_SIZE).
  # @option options [Integer] :batch_size The number of users to fetch per request (default: BATCH_SIZE).
  # @return [Array<Hash>] An array of hashes representing the users. Each user Hash includes the
  #   requested fields. Returns an empty Array if a request or parsing error occurs.
  #
  # @example Fetch 5 users with the name and email fields:
  #   fetch_users(fields: ['name', 'email'], size: 5)
  #   # => [{'name' => ..., 'email' => ...}, {'name' => ..., 'email' => ...}, ...]
  def fetch_users(fields: DEFAULT_FIELDS, size: DEFAULT_SIZE, batch_size: BATCH_SIZE)
    fields = permitted_fields(fields)
    total_size = size
    batch_size = [batch_size, size].min

    users = []
    while users.size < total_size
      fetch_size = [total_size - users.size, batch_size].min
      users.concat(fetch_batch(fields, fetch_size))
    end

    users
  end

  private

  def fetch_batch(fields, size)
    uri = construct_uri(fields, size)
    response = perform_request(uri)

    parse_response(response)
  end

  def construct_uri(fields, size)
    url = "#{BASE_URL}?results=#{size}"
    url += "&inc=#{fields.join(',')}" if fields.present?

    URI(url)
  end

  def permitted_fields(fields)
    (fields & ALLOWED_FIELDS).presence || DEFAULT_FIELDS
  end

  def perform_request(uri)
    res = Net::HTTP.get_response(uri)

    res.is_a?(Net::HTTPSuccess) ? res : nil
  end

  def parse_response(res)
    return [] if res.blank?

    begin
      JSON.parse(res.body)['results']
    rescue JSON::ParserError
      []
    end
  end
end
