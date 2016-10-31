class Salary
  def performance
    performance = data['performance']

    {
      current: performance['last-month'],
      last: performance['second-to-last-month']
    }
  end

  def salaries
    salaries = data['salaries']['one-year-back']

    # it seems that somehow x needs to be in seconds
    salaries.reverse.map.with_index do |entry, index|
      {
        x: index + 1,
        y: entry['salary'],
        moreinfo_value: entry['workload']
      }
    end
  end

  private

  def data
    @data ||= PanterApi.fetch('salary')
  end
end
