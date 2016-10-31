def update_code
  code = Code.new

  # commits
  send_event('commits', code.commits)

  # pr comments
  send_event('pull-request-comments', code.pull_request_comments)

  # line changes
  send_event('additions-deletions', code.additions_deletions)

  # languages
  send_event('programming-languages', code.programming_languages)

  # frameworks
  send_event('frameworks', code.frameworks)
end

update_code

SCHEDULER.every '10m' do
  update_code
end
