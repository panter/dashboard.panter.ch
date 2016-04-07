# Panter Dashboard

![Screenshot](screenshot.png)

Built with [Dashing](https://shopify.github.io/dashing/).

## Components used

* Redis
* Panter Controllr
* Github
* Gitlab

## Setup

* Install ruby (`rbenv` recommended)
* Install redis
* `cp .env.example .env` and fill in some values (esp. the access tokens)
* `cp config/salaries.yml.sample config/salaries.yml` and fill in some values
* `bundle`
* `rake clone_git_repositories` to have all git repositories locally
  alternatively you can rsync the cloned repositories from the dashboard
  production server.
* `dashing s`

## License

Licensed under the [GNU General Public License v3.0](LICENSE)
