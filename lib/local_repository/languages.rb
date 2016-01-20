require 'rugged'
require 'linguist'
require './lib/local_repository/local_repository_base'

class Languages < LocalRepositoryBase
  def absolute_values
    valid_directories
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
      .to_h
  end
end
