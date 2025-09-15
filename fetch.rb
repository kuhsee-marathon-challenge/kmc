# frozen_string_literal: true
# Helper class to get participants

require 'cgi'
require 'json'
require 'net/http'
require 'openssl'
require 'uri'

class Fetch
  attr_reader :participants

  URL = 'https://api.raceresult.com/341874/TNKGN05GJEXNIZ6CHO60K46S9MZNAN5N'

  def initialize(url = URL)
    # URL to fetch data from
    uri = URI(url)

    # Set up HTTP connection with SSL verification disabled
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # Make the request
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    body = response.body

    # Parse the JSON response
    json_data = JSON.parse(body)

    # Extract DataFields and Data
    data_fields = json_data['DataFields']
    data_entries = json_data['Data'].values.flatten(1)

    # Convert each data row into a hash using DataFields as keys
    @participants = data_entries.map do |entry|
      Hash[data_fields.zip(entry)]
    end
  end
end
