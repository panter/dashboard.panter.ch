require 'json'

def user_count(employment)
  api_url = "http://controllr.panter.biz/users.json?&iDisplayLength=1000&search[active_in][]=true&search[employment_in][]=%{employment}&user_token=%{token}"

  url = format(api_url, employment: employment, token: ENV['CONTROLLR_TOKEN'])
  json = Net::HTTP.get(URI(url))
  data = JSON.parse(json)
  data.fetch('iTotalDisplayRecords', 0)
end

def performance(month)
  api_url = 'http://controllr.panter.biz/api/monthly_salaries/spreadsheet_data.json?month=%{month}&user_token=%{token}'
  url = format(api_url, month: month, token: ENV['CONTROLLR_TOKEN'])
  json = Net::HTTP.get(URI(url))
  data = JSON.parse(json)
  data_totals = data['totals']

  performance = data_totals['internal_hours_billable'].to_f / data_totals['internal_hours_worked'].to_f

  performance.round(2)
end

def update
  employees = user_count('employee')
  contractors = user_count('external')

  send_event('employees', { current: employees })
  send_event('contractors', { current: contractors })

  last_performance = performance(5)
  current_performance = performance(6)

  send_event('salary-performance', { current: current_performance, last: last_performance })
  send_event('code-coverage',   { value: 97.8 })
end

update
SCHEDULER.every '1d' do
  update
end
