# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'dashboard.panter.ch'
set :repo_url, 'git@github.com:panter/dashboard.panter.ch.git'
set :rails_env, 'production'

set :user, 'app'
set :deploy_to, -> { "/home/#{fetch(:user)}/app" }
set :ssh_options, -> { { user: fetch(:user), forward_agent: true } }
set :log_level, :info
set :rails_env, 'production'

set :rbenv_ruby, open("#{ Bundler.root }/.ruby-version").read.strip

set :bundle_jobs, 2

set :linked_files, ['.env', 'config/salaries.yml']
set :linked_dirs, ['repositories']

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:app), in: :sequence do
      with rails_env: fetch(:rails_env) do
        execute '$HOME/bin/unicorn_wrapper', 'restart'
      end
    end
  end
  after :publishing, :restart
end
