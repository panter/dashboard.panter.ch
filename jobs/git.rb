def update
  # commits
  send_event('commits', DataStore.get('commits'))

  # pr comments
  send_event('pull-request-comments', DataStore.get('pull-request-comments'))

  # line changes
  send_event('additions-deletions', DataStore.get('additions-deletions'))

  # languages
  send_event('programming-languages', DataStore.get('programming-languages'))

  # frameworks
  send_event('frameworks', DataStore.get('frameworks'))
end

# in development mode we don't rely on the cron jobs
if !Configuration.git_enabled?
  puts '--> Skipping git data fetching.'
elsif development?
  puts '--> Fetching git data...'
  require 'rake'
  Rake.load_rakefile('./Rakefile')
  Rake::Task[:'data:git'].invoke
end

update

SCHEDULER.every '10m' do
  update
end
