require 'rugged'
require 'linguist'

class Languages < LocalRepositoryBase
  def as_percentages
    numbers = Hash[
      *valid_directories
        .map { |directory| Rugged::Repository.new(directory) }
        .reject { |repository| repository.head_unborn? }
        .map do |repository|
          project = Linguist::Repository.new(repository, repository.head.target_id)
          project.languages
        end
        .inject({}) do |hash, merge_hash|
          hash.merge(merge_hash) { |key, oldval, newval| newval + oldval }
        end
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
