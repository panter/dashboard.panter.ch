require 'json'

class JsonApi
  def self.fetch(url, params = {})
    encoded_params = URI.encode_www_form(params)
    url = "#{url}?#{encoded_params}"

    begin
      json = Net::HTTP.get(URI(url))
    rescue
      raise "The API at '#{url}' could not be reached.\nMaybe you should update your environment variable that points to the API?\n"
    end

    JSON.parse(json)
  end
end
