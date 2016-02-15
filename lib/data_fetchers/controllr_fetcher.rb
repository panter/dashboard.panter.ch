require 'yaml'
require './lib/data_store'
require './lib/controllr'

class ControllrFetcher
  def initialize
    @controllr = Controllr.new
  end

  def run
    employment
    performance
    working_hours
    salaries
    average_age
  end

  private

  attr_reader :controllr

  def employment
    employees = controllr.employee_count
    contractors = controllr.contractor_count

    DataStore.set('employees', { current: employees })
    DataStore.set('contractors', { current: contractors })
  end

  def performance
    performance_month = Date.today.prev_month.prev_month
    last_performance = controllr.performance(performance_month.prev_month.month, performance_month.year)
    current_performance = controllr.performance(performance_month.month, performance_month.year)

    DataStore.set('salary-performance', { current: current_performance, last: last_performance })
  end

  def working_hours
    hours_worked = controllr.hours_worked(Date.today.month, Date.today.year)
    DataStore.set('hours-worked', { current: hours_worked })
  end

  def salaries
    years_salaries = YAML.load_file('config/salaries.yml')

    to_month = Date.today.prev_month.prev_month
    # get the first day of the month to be able to properly iterate
    # (see iteration comment below)
    to_month = Date.new(to_month.year, to_month.month, 1)
    from_month = to_month << 11
    # select the first day only, otherwise the iteration includes every day
    months = (from_month..to_month).select { |month| month.day == 1 }

    points = months.map do |month|
      salary, workload = years_salaries[month.year][month.month]

      {
        x: month.month,
        y: salary,
        moreinfo_value: workload
      }
    end

    DataStore.set('salary-graph', points: points)
  end

  def average_age
    average_age = controllr.average_age
    DataStore.set('average-age', { current: average_age })
  end
end
