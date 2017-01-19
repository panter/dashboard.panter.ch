def update_staff
  AppLogger.info 'Starting update_staff...'

  staff = Staff.new

  # employment
  send_event('employees', points: staff.employees)
  send_event('contractors', staff.contractors)

  # working hours
  send_event('hours-worked', staff.hours_worked)

  # average age
  send_event('average-age', staff.average_age)

  # shortest / longest distance to the office
  send_event('commute-distances', staff.commute_distances)

  # children per employee
  send_event('children-per-employee', staff.children_per_employee)

  AppLogger.info 'Finished update_staff'
rescue => error
  AppLogger.error "#{error.class} in update_staff: #{error.message}\n#{error.backtrace.join "\n"}"
end

update_staff

SCHEDULER.every '10m' do
  update_staff
end
