require 'octokit'

client = Octokit::Client.new(:login => ENV['GITHUB_LOGIN'], :password => ENV['GITHUB_PASSWORD'])

SCHEDULER.every '10m' do
  commits = client.organization_events('panter', per_page: 1000)
    .select { |x| x.type == 'PushEvent' && x.created_at.to_date == Date.today }
    .map(&:payload)
    .flat_map(&:commits)
    .length

  send_event('commits', { current: commits })
end
