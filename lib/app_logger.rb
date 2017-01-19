require 'logger'
require 'singleton'

class AppLogger < Logger
  include Singleton

  def initialize
    super("#{Bundler.root}/log/application.log")
  end

  class << self
    extend Forwardable
    def_delegators :instance, *Logger::Severity.constants.map(&:downcase)
  end
end
