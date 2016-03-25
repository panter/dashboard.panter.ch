require './lib/json_api'

class PublicTransport
  API_ENDPOINT = 'http://transport.opendata.ch/v1/connections'

  def self.connection_duration(from, to)
    result = JsonApi.fetch(API_ENDPOINT, {
      from: from,
      to: to,
      limit: 4
    })

    # duration in the format '00d00:30:00'
    durations = result['connections'].map { |connection| connection['duration'] }
    # convert to minutes
    minutes = durations.map do |duration|
      duration[-8..-7].to_i * 60 + # hours
        duration[-5..-4].to_i # minutes
    end

    # get the fastest connection
    minutes.sort.first
  end
end
