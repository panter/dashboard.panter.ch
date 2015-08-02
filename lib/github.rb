require 'octokit'

class Github
  attr_reader :client

  def initialize
    @client = Octokit::Client.new(:login => ENV['GITHUB_USER'], :access_token => ENV['GITHUB_TOKEN'])
  end

  # @return http://www.rubydoc.info/github/pengwynn/octokit/Octokit/Client/Events#organization_events-instance_method
  def events
    @events ||=
      begin
        events = client.organization_events('panter')

        # get all today's events
        last_response = client.last_response
        while events.last.created_at.to_date == Date.today && last_response.rels[:next]
          last_response = last_response.rels[:next].get
          events += last_response.data
        end
        events.select { |event| event.created_at.to_date == Date.today }
      end
  end

  # @return [Fixnum] the number of commits
  # @see {#events} for the range of events that are considered.
  def commits
    events
      .select { |event| event.type == 'PushEvent' }
      .map(&:payload)
      .flat_map(&:commits)
      .map(&:sha)
      .uniq
      .length
  end

  # @return [Fixnum] the number of pull request comments
  def pull_request_comments
    events
      .select { |event| event.type == 'PullRequestReviewCommentEvent' }
      .length
  end

  # all repositories
  #
  # @return http://www.rubydoc.info/github/pengwynn/octokit/Octokit/Client/Organizations#organization_repositories-instance_method
  def repositories
    @repositories ||=
      begin
        repositories = client.organization_repositories('panter')
        last_response = client.last_response
        while last_response.rels[:next]
          last_response = last_response.rels[:next].get
          repositories += last_response.data
        end
        repositories
      end
  end

  # all owned repositories (i.e. excluding forks)
  #
  # @return http://www.rubydoc.info/github/pengwynn/octokit/Octokit/Client/Organizations#organization_repositories-instance_method
  def own_repositories
    @own_repositories ||= repositories.reject(&:fork)
  end

  # @return [Hash{Symbol=>Fixnum}] the number of line additions
  #   and deletions in the form `{ additions: <Fixnum>, deletions: <Fixnum>}`
  def code_frequency_stats
    @code_frequency_stats ||=
      begin
        statistics = repositories.map(&:full_name).map do |repo_name|
          client.code_frequency_stats(repo_name)
        end
          .compact
          .map(&:last) # the last entry is the current week

        additions = statistics.map { |statistic| statistic[-2] }.inject(:+)
        deletions = statistics.map { |statistic| statistic[-1] }.inject(:+)

        { additions: additions, deletions: deletions }
      end
  end

  # @return [Hash{Symbol=>Float}] the languages with the overall percentage
  #   as value and the language name as key.
  def languages
    @languages ||=
      begin
        languages = own_repositories.map(&:full_name).map do |repo_name|
          client.languages(repo_name)
        end.reject { |resource| resource.attrs.empty? }

        # collapse all the hashes into one, sum up the values
        grouped = Hash.new(0)
        languages.each do |language_hash|
          language_hash.each { |language| grouped[language.first] += language.last }
        end

        percent_factor = 100 / grouped.values.inject(&:+).to_f

        # convert to percent and sort
        grouped = grouped.map do |language|
          [language.first, (percent_factor * language.last).round(2)]
        end.sort_by(&:last).reverse.to_h
      end
  end
end
