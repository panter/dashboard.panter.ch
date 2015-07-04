SCHEDULER.every '2s' do
  last_performance = 0.65
  current_performance = 0.72
  employees = 25
  contractors = 5

  send_event('salary-performance', { current: current_performance, last: last_performance })
  send_event('employees', { current: employees })
  send_event('contractors', { current: contractors })
  send_event('code-coverage',   { value: 97.8 })
end
