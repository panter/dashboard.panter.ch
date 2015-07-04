SCHEDULER.every '2s' do
  last_performance = 0.65
  current_performance = 0.72
  last_employees = 25
  current_employees = 25
  last_contractors = 25
  current_contractors = 5

  send_event('salary-performance', { current: current_performance, last: last_performance })
  send_event('employees', { current: current_employees, last: last_employees })
  send_event('contractors', { current: current_contractors, last: last_contractors })
  send_event('code-coverage',   { value: 97.8 })
end
