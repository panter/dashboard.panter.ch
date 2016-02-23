def update
  # in development mode we don't rely on the cron jobs
  unless production?
    require 'rake'
    Rake.load_rakefile('./Rakefile')
    Rake::Task[:'data:controllr'].invoke
  end

  # employment
  send_event('employees', DataStore.get('employees'))
  send_event('contractors', DataStore.get('contractors'))

  # performance
  send_event('salary-performance', DataStore.get('salary-performance'))

  # working hours
  send_event('hours-worked', DataStore.get('hours-worked'))

  # salaries per month
  send_event('salary-graph', DataStore.get('salary-graph'))

  # average age
  send_event('average-age', DataStore.get('average-age'))

  # shortest / longest distance to the office
  send_event('commute-distances', DataStore.get('commute-distances'))
end

update

SCHEDULER.every '10m' do
  update
end
