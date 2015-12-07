require 'technologist'

class Frameworks
  attr_reader :directories

  def initialize(directories)
    @directories = directories
  end

  def as_percentages
    numbers = Hash[
      *directories
        .map { |directory| "repositories/#{directory}" }
        .select { |directory| Dir.exist?(directory) }
        .map do |directory|
          # don't bail on broken repositores
          Technologist::Repository.new(directory).frameworks rescue []
        end
        .flatten
        .inject(Hash.new(0)) { |hash, value| hash[value] += 1; hash }
        .sort_by { |key, value| value }
        .reverse
        .flatten
    ]

    # total count
    total = numbers.values.inject(&:+)

    # convert to percent
    numbers.each {|key, value| numbers[key] = (100.0 / total * value).round(2) }

    numbers
  end
end
