require 'octokit'

def update
  github = Github.new

  send_event('commits', { current: github.commits })
  send_event('pull-request-comments', { current: github.pull_request_comments })
  send_event('additions-deletions', {
    value1: github.code_frequency_stats[:additions],
    value2: github.code_frequency_stats[:deletions].abs
  })
  languages = github.languages.map { |language| { label: language.first, value: "#{language.last}%" } }.take(8)
  send_event('programming-languages', items: languages)
end

update

SCHEDULER.every '1m' do
  update
end
