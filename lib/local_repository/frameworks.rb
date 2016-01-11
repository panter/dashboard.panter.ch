require 'technologist'
require './lib/local_repository/local_repository_base'

class Frameworks < LocalRepositoryBase
  def as_percentages
    numbers = Hash[
      *valid_directories
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
    numbers.each { |key, value| numbers[key] = (100.0 / total * value).round(2) }

    numbers
  end
end

