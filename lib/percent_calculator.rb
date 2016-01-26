class PercentCalculator
  # @param hash[String, Integer] A hash of keys and corresponding numeric values
  #
  # @return the percent on each of the keys
  def self.to_percent(absolute_values)
    # total count
    total = absolute_values.values.inject(&:+)

    # convert to percent
    percent_values = absolute_values.map { |key, value| [key, (100.0 / total * value).round(2)] }
    
    # sort by biggest value
    percent_values
      .sort_by { |key, value| value }
      .reverse
      .to_h
  end
end
