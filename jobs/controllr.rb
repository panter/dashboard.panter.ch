def update
  controllr = Controllr.new

  # employment
  employees = controllr.employee_count
  contractors = controllr.contractor_count

  send_event('employees', { current: employees })
  send_event('contractors', { current: contractors })

  # performance
  last_performance = controllr.performance(Date.today.prev_month.prev_month.month)
  current_performance = controllr.performance(Date.today.prev_month.month)

  send_event('salary-performance', { current: current_performance, last: last_performance })
end

update

SCHEDULER.every '1d' do
  update
end
