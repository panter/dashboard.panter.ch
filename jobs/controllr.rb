require 'json'

def user_count(employment)
  users_url = "http://controllr.panter.biz/users.json?&iDisplayLength=1000&search[active_in][]=true&search[employment_in][]=%{employment}&user_token=%{token}"

  url = format(users_url, employment: employment, token: ENV['CONTROLLR_TOKEN'])
  json = Net::HTTP.get(URI(url))
  data = JSON.parse(json)
  data.fetch('iTotalDisplayRecords', 0)
end

def update
  employees = user_count('employee')
  contractors = user_count('external')

  send_event('employees', { current: employees })
  send_event('contractors', { current: contractors })
end

update
SCHEDULER.every '1d' do
  update
end
