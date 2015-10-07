require 'gitlab'

class GitlabClient
  def initialize
    Gitlab.endpoint = 'https://git.panter.ch/api/v3'
    Gitlab.private_token = ENV['GITLAB_PRIVATE_TOKEN']
  end

  def projects
    @projects ||=
      begin
        projects = paginate(:projects, options: { scope: :all })

        # exclude projects without proper repositories
        projects.select{ |project| project.default_branch }
      end
  end

  def projects_active_today
    projects.select { |project| Date.parse(project.last_activity_at) == Date.today }
  end

  def commits_per_project
    @commits_per_project ||=
      begin
        commits = {}
        projects_active_today.each do |project|
          commits[project.id] = paginate(
            :commits,
            args: [project.id],
            select_condition: -> (page) { Date.parse(page.created_at) == Date.today }
          )
        end

        commits
      end
  end

  def commits
    commits_per_project.values.inject(&:+)
  end

  # @return [Hash{Symbol=>Fixnum}] the number of line additions
  #   and deletions in the form `{additions: <Fixnum>, deletions: <Fixnum>}`
  def line_changes
    @line_changes ||=
      begin
        line_changes = { additions: 0, deletions: 0 }

        commits_per_project.each do |project, commits|
          commits.each do |commit|
            Gitlab.commit_diff(project, commit.id).each do |diff|
              change = diff.diff[/@@ (.+) @@/, 1]
              # diff may not contain line changes (e.g. file rename)
              if change
                line_changes[:deletions] += change[/-\d+,(\d+)/, 1].to_i
                line_changes[:additions] += change[/\+\d+,(\d+)/, 1].to_i
              end
            end
          end
        end

        line_changes
      end
  end

  # @return [Fixnum] the number of today's commits
  def commits_count
    commits.length
  end

  private

  def paginate(method, args: [], options: {}, select_condition: nil)
    options.merge!(per_page: 100, page: 0)

    results = []
    loop do
      page_result = Gitlab.send(method, *(args + [options]))

      break if page_result.empty?

      results += page_result

      # 1) don't retrieve new pages if the condition isn't met anymore
      break if select_condition && !select_condition.call(page_result.last)

      options[:page] = options[:page] + 1
    end

    # 2) although 1) has cancelled any more fetching of pages, we still
    # need to filter out the unmatched entries
    select_condition ? results.select(&select_condition) : results
  end
end
