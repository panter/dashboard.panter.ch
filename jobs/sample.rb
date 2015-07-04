current_performance = 0
current_karma = 0

SCHEDULER.every '2s' do
  last_performance = 0.65
  current_performance = 0.72
  last_karma     = current_karma
  current_karma     = rand(200000)

  send_event('salary-performance', { current: current_performance, last: last_performance })
  send_event('karma', { current: current_karma, last: last_karma })
  send_event('code-coverage',   { value: 97.8 })
end
