def update_code
  AppLogger.info 'Starting update_code...'

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

  AppLogger.info 'Finished update_code'
rescue => error
  AppLogger.error "#{error.class} in update_code: #{error.message}\n#{error.backtrace.join "\n"}"
end

update_code
