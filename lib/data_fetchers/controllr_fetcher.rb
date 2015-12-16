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
    last_performance = controllr.performance(performance_month.prev_month.month)
    current_performance = controllr.performance(performance_month.month)

    DataStore.set('salary-performance', { current: current_performance, last: last_performance })
  end

  def working_hours
    hours_worked = controllr.hours_worked(Date.today.month)
    DataStore.set('hours-worked', { current: hours_worked })
  end

  def salaries
    points = YAML.load_file('config/salaries.yml')[Date.today.year].map do |key, value|
      {
        x: key,
        y: value[0],
        moreinfo_value: value[1]
      }
    end

    DataStore.set('salary-graph', points: points)
  end
end
