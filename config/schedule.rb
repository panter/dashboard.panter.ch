every 10.minutes do
  rake 'data:git'
end

every 1.day, at: '2:30 am' do
  rake 'data:controllr'
end

every 1.day, at: '3:30 am' do
  rake 'clone_git_repositories'
end
