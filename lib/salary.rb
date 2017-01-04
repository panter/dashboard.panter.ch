class Salary
  def performance
    performance = data.performance

    {
      current: performance.lastMonth,
      last: performance.secondToLastMonth
    }
  end

  def salaries
    salaries = data.salaries.oneYearBack

    # it seems that somehow x needs to be in seconds
    salaries.map.with_index do |entry, index|
      {
        x: index + 1,
        y: entry.salary,
        moreinfo_value: entry.workload
      }
    end
  end

  private

  def data
    @data ||= PanterApi.fetch('salary')
  end
end
