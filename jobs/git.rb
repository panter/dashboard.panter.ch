def update
  github = Github.new
  gitlab = GitlabClient.new

  # commits
  send_event('commits', { current: github.commits_count + gitlab.commits_count })

  # pr comments
  send_event('pull-request-comments', {
    current: github.pull_request_comments_count + gitlab.pull_request_comments_count
  })

  # line changes
  send_event('additions-deletions', {
    value1: github.line_changes[:additions] + gitlab.line_changes[:additions],
    value2: github.line_changes[:deletions] + gitlab.line_changes[:deletions]
  })

  # languages
  languages = github.languages.map do |language, percent|
    { label: language, value: "#{percent}%" }
  end.take(8)

  send_event('programming-languages', items: languages)

  # frameworks
  frameworks = github.frameworks.merge(gitlab.frameworks) { |key, value1, value2| (value1 + value2).round }
  frameworks = frameworks.map do |framework, percent|
    { label: framework, value: "#{percent}%" }
  end.take(8)

  send_event('frameworks', items: frameworks)
end

update

SCHEDULER.every '10m' do
  update
end
