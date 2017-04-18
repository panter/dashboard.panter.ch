# config valid only for current version of Capistrano
lock '3.8.0'

set :application, 'dashboard.panter.ch'
set :repo_url, 'git@github.com:panter/dashboard.panter.ch.git'

append :linked_files, '.env', 'config/salaries.yml'
append :linked_dirs, 'log', 'repositories'
