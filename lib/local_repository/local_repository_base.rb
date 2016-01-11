class LocalRepositoryBase
  attr_reader :directories

  def initialize(directories)
    @directories = directories
  end

  def valid_directories
    directories
      .map { |directory| "repositories/#{directory}" }
      .select { |directory| Dir.exist?(directory) }
  end
end
