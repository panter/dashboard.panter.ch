def update_salary
  salary = Salary.new

  # performance
  send_event('salary-performance', salary.performance)

  # salaries per month
  send_event('salary-graph', points: salary.salaries)
end

update_salary

SCHEDULER.every '10m' do
  update_salary
end
