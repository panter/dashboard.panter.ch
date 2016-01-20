require './lib/data_store'
require './lib/github'
require './lib/gitlab_client'
require './lib/percent_calculator'

class GitFetcher
  def initialize
    @github = Github.new
    @gitlab = GitlabClient.new
  end

  def run
    commits
    pr_comments
    line_changes
    languages
    frameworks
  end

  private

  attr_reader :github, :gitlab

  def commits
    DataStore.set('commits', { current: github.commits_count + gitlab.commits_count })
  end

  def pr_comments
    DataStore.set('pull-request-comments', {
      current: github.pull_request_comments_count + gitlab.pull_request_comments_count
    })
  end

  def line_changes
    DataStore.set('additions-deletions', {
      value1: github.line_changes[:additions] + gitlab.line_changes[:additions],
      value2: github.line_changes[:deletions] + gitlab.line_changes[:deletions]
    })
  end

  def languages
    languages = github.languages
    languages.merge!(gitlab.languages) { |key, value1, value2| languages[key] = value1 + value2 }

    languages = PercentCalculator.to_percent(languages).take(8).to_h

    languages = languages.map do |language, percent|
      { label: language, value: "#{percent}%" }
    end

    DataStore.set('programming-languages', items: languages)
  end

  def frameworks
    frameworks = github.frameworks
      .merge(gitlab.frameworks) { |key, value1, value2| ((value1 + value2 / 2.0)).round }
      .sort_by { |key, value| value }
      .reverse
      .take(8)
      .to_h

    frameworks = frameworks.map do |framework, percent|
      { label: framework, value: "#{percent}%" }
    end

    DataStore.set('frameworks', items: frameworks)
  end
end
