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
    to_month = Date.today.prev_month.prev_month
    years_salaries = YAML.load_file('config/salaries.yml')[to_month.year]
    years_salaries = (1..to_month.month).map { |month| [month, years_salaries[month]] }.to_h
    points = years_salaries.map do |key, value|
      {
        x: key,
        y: value[0],
        moreinfo_value: value[1]
      }
    end

    DataStore.set('salary-graph', points: points)
  end

  def average_age
    average_age = controllr.average_age
    DataStore.set('average-age', { current: average_age })
  end
end
