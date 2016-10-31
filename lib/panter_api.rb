class PanterApi
  URL = ENV['PANTER_API_ENDPOINT']

  def self.fetch(method)
    JsonApi.fetch("#{URL}/#{method}")
  end
end
