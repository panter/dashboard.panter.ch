require 'octokit'

def update
  client = Octokit::Client.new(:login => ENV['GITHUB_LOGIN'], :password => ENV['GITHUB_PASSWORD'])

  events = client.organization_events('panter')

  # get all today's events
  last_response = client.last_response
  while events.last.created_at.to_date == Date.today
    last_response = last_response.rels[:next].get
    events += last_response.data
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

update

SCHEDULER.every '1m' do
  update
end
