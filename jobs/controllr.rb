def update
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

  # children per employee
  send_event('children-per-employee', DataStore.get('children-per-employee'))
end

# in development mode we don't rely on the cron jobs
if !Configuration.controllr_enabled?
  puts '--> Skipping controllr data fetching.'
elsif development?
  puts '--> Fetching controllr data...'
  require 'rake'
  Rake.load_rakefile('./Rakefile')
  Rake::Task[:'data:controllr'].invoke
end

update

SCHEDULER.every '10m' do
  update
end
