require 'octokit'

class Github
  attr_reader :client

  def initialize
    @client = Octokit::Client.new(:login => ENV['GITHUB_LOGIN'], :password => ENV['GITHUB_PASSWORD'])
  end

  def events
    @events ||=
      begin
        @events = client.organization_events('panter')

        # get all today's events
        last_response = client.last_response
        while @events.last.created_at.to_date == Date.today && last_response.rels[:next]
          last_response = last_response.rels[:next].get
          @events += last_response.data
        end
        @events.select! { |event| event.created_at.to_date == Date.today }
      end
  end

  def commits
    events
      .select { |event| event.type == 'PushEvent' }
      .map(&:payload)
      .flat_map(&:commits)
      .map(&:sha)
      .uniq
      .length
  end

  def pull_request_comments
    events
      .select { |event| event.type == 'PullRequestReviewCommentEvent' }
      .length
  end

  # all public or private repositories, excluding forks
  def own_repositories
    @own_repositories ||=
      begin
        @own_repositories = client.organization_repositories('panter', type: [:public, :private])
        last_response = client.last_response
        while last_response.rels[:next]
          last_response = last_response.rels[:next].get
          @own_repositories += last_response.data
        end
        @own_repositories
      end
  end

  def code_frequency_stats
    @code_frequency_stats ||=
      begin
        statistics = own_repositories.map(&:full_name).map do |repo_name|
          stats = client.code_frequency_stats(repo_name)
          if stats
            stats.last
          end
        end
          .compact
          .reject { |statistic| statistic[-2] == 0 && statistic[-1] == 0 }

        additions = statistics.map { |statistic| statistic[-2] }.inject(:+)
        deletions = statistics.map { |statistic| statistic[-1] }.inject(:+)

        { additions: additions, deletions: deletions }
      end
  end
end
