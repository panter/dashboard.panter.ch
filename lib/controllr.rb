require 'json'

class Controllr
  def employee_count
    user_count('employee')
  end

  def contractor_count
    user_count('external')
  end

  def user_count(employment)
    data = fetch("/users.json?&iDisplayLength=1000&search[active_in][]=true&search[employment_in][]=#{employment}")
    data.fetch('iTotalDisplayRecords', 0)
  end

  # @param month [Fixnum] the month as a number (starting at 1 for January), see `Date#month`.
  def performance(month)
    data = fetch("/api/monthly_salaries/spreadsheet_data.json?month=#{month}")
    data_totals = data['totals']

    performance = data_totals['internal_hours_billable'].to_f / data_totals['internal_hours_worked'].to_f

    performance.round(2)
  end

  private

  def fetch(api_url)
    url = url(api_url)
    json = Net::HTTP.get(URI(url))
    JSON.parse(json)
  end

  def url(api_url)
    base = 'http://controllr.panter.biz'
    token = "&user_token=#{ENV['CONTROLLR_TOKEN']}"

    "#{base}#{api_url}#{token}"
  end
end
