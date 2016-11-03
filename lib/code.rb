class Code
  def commits
    commits = data.commits.count

    { current: commits }
  end

  def pull_request_comments
    comments = data.pullRequestComments.count

    { current: comments }
  end

  def additions_deletions
    additions = data.lineAdditions.count
    deletions = data.lineDeletions.count

    {
     value1: additions,
     value2: deletions
    }
  end

  def programming_languages
    languages = data.programmingLanguages.take(8).map do |language|
      { label: language.name, value: "#{language.percentage}%" }
    end

    { items: languages }
  end

  def frameworks
    frameworks = data.frameworks.take(8).map do |framework|
      { label: framework.name, value: "#{framework.percentage}%" }
    end

    { items: frameworks }
  end

  private

  def data
    @data ||= PanterApi.fetch('code')
  end
end
