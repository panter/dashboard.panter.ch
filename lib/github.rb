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
end
