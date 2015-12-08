require 'rugged'
require './lib/github'
require './lib/gitlab_client'

class GitRepositoryCloner
  def run
    thread1 = Thread.new { github }
    thread2 = Thread.new { gitlab }
    thread1.join
    thread2.join
  end

  private

  def github
    clone_or_update(
      ENV['GITHUB_USER'],
      ENV['GITHUB_TOKEN'],
      Github.new.own_repositories,
      :clone_url
    )
  end

  def gitlab
    clone_or_update(
      ENV['GITLAB_USER'],
      ENV['GITLAB_PASSWORD'],
      GitlabClient.new.projects,
      :http_url_to_repo
    )
  end

  def clone_or_update(user, password, repositories, clone_method)
    credentials = Rugged::Credentials::UserPassword.new(
      username: user,
      password: password
    )

    repositories.each do |repository|
      target_directory = "repositories/#{repository.name}"

      if Dir.exist?(target_directory)
        puts "Updating #{repository.name}"
        repository = Rugged::Repository.new(target_directory)
        repository.fetch('origin', credentials: credentials)
      else
        puts "Cloning #{repository.name}"
        Rugged::Repository.clone_at(
          repository.send(clone_method),
          target_directory,
          bare: true,
          credentials: credentials
        )
      end
    end
  end
end
