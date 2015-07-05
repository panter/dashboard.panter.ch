require 'octokit'

client = Octokit::Client.new(:login => ENV['GITHUB_LOGIN'], :password => ENV['GITHUB_PASSWORD'])

SCHEDULER.every '10m' do
  events = client.organization_events('panter')

  # get all today's events
  while events.last.created_at.to_date == Date.today
    events << client.organization_events('panter')
  end
  events.select! { |event| event.created_at.to_date == Date.today }

  commits = events
    .select { |event| event.type == 'PushEvent' }
    .map(&:payload)
    .flat_map(&:commits)
    .length

  pull_request_comments = events
    .select { |event| event.type == 'PullRequestReviewCommentEvent' }
    .length

  send_event('commits', { current: commits })
  send_event('pull-request-comments', { current: pull_request_comments })
end
