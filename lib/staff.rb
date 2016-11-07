class Staff
  def employees
    employees = data.employees.count

    { current: employees }
  end

  def contractors
    employees = data.contractors.count

    { current: employees }
  end

  def hours_worked
   hours = data.hoursWorked.currentMonth

   { current: hours }
  end

  def average_age
    age = data.age.average

    { current: age }
  end

  def commute_distances
    distances = data.commuteDistances
    shortest = distances.shortest
    longest = distances.longest

    {
      value1: "#{shortest.duration} / #{shortest.distance}",
      value2: "#{longest.duration} / #{longest.distance}"
    }
  end

  def children_per_employee
    children = data.childrenPerEmployee.count

    { current: children }
  end

  private

  def data
    @data ||= PanterApi.fetch('staff')
  end
end
