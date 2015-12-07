def update
  # in development mode we don't rely on the cron jobs
  unless production?
    require 'rake'
    Rake.load_rakefile('./Rakefile')
    Rake::Task[:'data:git'].invoke
  end

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

update

SCHEDULER.every '10m' do
  update
end
