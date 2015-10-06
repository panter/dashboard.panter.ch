require 'octokit'

def update
  github = Github.new
  gitlab = GitlabClient.new

  send_event('commits', { current: github.commits_count + gitlab.commits_count })

  send_event('pull-request-comments', { current: github.pull_request_comments_count })

  send_event('additions-deletions', {
    value1: github.line_changes[:additions],
    value2: github.line_changes[:deletions].abs
  })

  languages = github.languages.map do |language|
    { label: language.first, value: "#{language.last}%" }
  end.take(8)

  send_event('programming-languages', items: languages)
end

update

SCHEDULER.every '10m' do
  update
end
