def update
  controllr = Controllr.new

  # employment
  employees = controllr.employee_count
  contractors = controllr.contractor_count

  send_event('employees', { current: employees })
  send_event('contractors', { current: contractors })

  # performance
  performance_month = Date.today.prev_month.prev_month
  last_performance = controllr.performance(performance_month.prev_month.month)
  current_performance = controllr.performance(performance_month.month)

  send_event('salary-performance', { current: current_performance, last: last_performance })

  # working hours
  hours_worked = controllr.hours_worked(Date.today.month)
  send_event('hours-worked', { current: hours_worked })

  # salaries per month
  points = YAML.load_file('config/salaries.yml')[Date.today.year].map { |key, value| { x: key, y: value } }
  send_event('salary-graph', points: points)
end

update

SCHEDULER.every '1d' do
  update
end
