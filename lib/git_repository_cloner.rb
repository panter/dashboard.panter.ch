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

  def clone_or_update(user, password, repositories, clone_url_method)
    credentials = Rugged::Credentials::UserPassword.new(
      username: user,
      password: password
    )

    repositories.each do |repository|
      target_directory = "repositories/#{repository.name}"
      remote_url = repository.send(clone_url_method)

      if Dir.exist?(target_directory)
        local_repository = Rugged::Repository.new(target_directory)
        origin = local_repository.remotes.select { |remote| remote.name == 'origin' }.first

        # make sure we don't mix up github and gitlab repositories
        # (this may be the case when e.g. a github repo is transferred
        # to gitlab, while the github repository is left in place. in
        # this scenario, we may be trying to fetch with the wrong
        # credentials)
        if origin && origin.url == remote_url
          puts "Updating #{repository.name}"
          local_repository.fetch('origin', credentials: credentials)
        else
          puts "Not updating #{repository.name}, we have the wrong remote (#{remote_url})."
        end
      else
        puts "Cloning #{repository.name}"
        Rugged::Repository.clone_at(
          remote_url,
          target_directory,
          bare: true,
          credentials: credentials
        )
      end
    end
  end
end
