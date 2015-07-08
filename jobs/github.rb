require 'octokit'

def update
  github = Github.new

  send_event('commits', { current: github.commits })
  send_event('pull-request-comments', { current: github.pull_request_comments })
end

update

SCHEDULER.every '1m' do
  update
end
