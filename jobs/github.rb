require 'octokit'

def update
  github = Github.new

  send_event('commits', { current: github.commits })
  send_event('pull-request-comments', { current: github.pull_request_comments })
  send_event('additions-deletions', {
    value1: github.code_frequency_stats[:additions],
    value2: github.code_frequency_stats[:deletions]
  })
end

update

SCHEDULER.every '1m' do
  update
end
