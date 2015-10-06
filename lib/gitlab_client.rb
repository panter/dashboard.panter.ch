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

  def commits
    @commits ||=
      begin
        commits = []
        projects_active_today.each do |project|
          commits += paginate(
            :commits,
            args: [project.id],
            select_condition: -> (page) { Date.parse(page.created_at) == Date.today }
          )
        end

        commits
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
