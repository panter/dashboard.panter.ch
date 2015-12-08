require 'dotenv'
Dotenv.load

desc 'Retrieves all data from all sources'
task data: [:'data:git', :'data:controllr']

namespace :data do
  desc 'Retrieves all data from the git repositories (github and gitlab)'
  task :git do
    require './lib/data_fetchers/git_fetcher'
    GitFetcher.new.run
  end

  desc 'Retrieves all data from the controllr'
  task :controllr do
    require './lib/data_fetchers/controllr_fetcher'
    ControllrFetcher.new.run
  end

  desc 'Clears all the data'
  task :clear do
    require './lib/data_store'
    DataStore.clear
  end
end
