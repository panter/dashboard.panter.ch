class Code
  def commits
    commits = data['commits']['count']

    { current: commits }
  end

  def pull_request_comments
    comments = data['pull-request-comments']['count']

    { current: comments }
  end

  def additions_deletions
    additions = data['line-additions']['count']
    deletions = data['line-deletions']['count']

    {
     value1: additions,
     value2: deletions
    }
  end

  def programming_languages
    languages = data['programming-languages'].take(8).map do |language, percent|
      { label: language, value: percent }
    end

    { items: languages }
  end

  def frameworks
    frameworks = data['frameworks'].take(8).map do |framework, percent|
      { label: framework, value: percent }
    end

    { items: frameworks }
  end

  private

  def data
    @data ||= PanterApi.fetch('code')
  end
end
