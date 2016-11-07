require 'json'

class JsonApi
  def self.fetch(url, params = {})
    encoded_params = URI.encode_www_form(params)
    url = "#{url}?#{encoded_params}"

    json = Net::HTTP.get(URI(url))
    JSON.parse(json)
  end
end
