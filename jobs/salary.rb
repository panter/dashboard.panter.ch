def update_salary
  AppLogger.info 'Starting update_salary...'

  salary = Salary.new

  # performance
  send_event('salary-performance', salary.performance)

  # salaries per month
  send_event('salary-graph', points: salary.salaries)

  AppLogger.info 'Finished update_salary'
rescue => error
  AppLogger.error "#{error.class} in update_salary: #{error.message}\n#{error.backtrace.join "\n"}"
end

update_salary

SCHEDULER.every '10m' do
  update_salary
end
