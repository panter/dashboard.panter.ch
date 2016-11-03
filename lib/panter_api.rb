require 'recursive-open-struct'

class PanterApi
  URL = ENV['PANTER_API_ENDPOINT']

  def self.fetch(method)
    RecursiveOpenStruct.new(JsonApi.fetch("#{URL}/#{method}"), recurse_over_arrays: true)
  end
end
