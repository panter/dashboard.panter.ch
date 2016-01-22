require 'json'
require './lib/age'

class Controllr
  def employee_count
    user_count('employee')
  end

  def contractor_count
    user_count('external')
  end

  def user_count(employment)
    data = user_data.select { |user| user['employment'] == employment }
    data.length
  end

  def average_age
    data = user_data.select { |user| user['employment'] == 'employee' }

    ages = data.map { |user|
      date_of_birth = Date.parse(user['date_of_birth'])
      Age.from_date(date_of_birth)
    }.compact

    ages.inject(&:+) / ages.length
  end

  # @param month [Fixnum] the month as a number (starting at 1 for January), see `Date#month`.
  def performance(month, year)
    data = fetch("/api/monthly_salaries/spreadsheet_data.json?month=#{month}&year=#{year}")
    data_totals = data['totals']
    performance = data_totals['internal_hours_billable'].to_f / data_totals['internal_hours_worked'].to_f

    performance.round(2)
  end

  def hours_worked(month, year)
    data = fetch("/api/monthly_salaries/spreadsheet_data.json?month=#{month}&year=#{year}")
    data_totals = data['totals']
    data_totals['internal_hours_worked'].to_i
  end

  private

  def user_data
    data = fetch("/api/users.json")
    data.select { |user| user['active'] }
  end

  def fetch(api_url)
    url = url(api_url)
    json = Net::HTTP.get(URI(url))
    JSON.parse(json)
  end

  def url(api_url)
    base = 'http://controllr.panter.biz'
    token = "user_token=#{ENV['CONTROLLR_TOKEN']}"
    query_start = api_url.include?('?') ? '&' : '?'

    "#{base}#{api_url}#{query_start}#{token}"
  end
end
