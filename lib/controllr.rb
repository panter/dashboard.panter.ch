require 'geocoder'
require 'redis'
require './lib/age'
require './lib/json_api'
require './lib/public_transport'

class Controllr
  API_ENDPOINT = 'http://controllr.panter.biz'

  def employee_count
    user_count('employee')
  end

  def contractor_count
    user_count('external')
  end

  def user_count(employment)
    data = user_data(employment: employment)
    data.length
  end

  def average_age
    data = user_data(employment: 'employee')

    ages = data.map { |user|
      date_of_birth = Date.parse(user['date_of_birth'])
      Age.from_date(date_of_birth)
    }.compact

    ages.inject(&:+) / ages.length
  end

  # @param month [Fixnum] the month as a number (starting at 1 for January), see `Date#month`.
  def performance(month, year)
    data = fetch('/api/monthly_salaries/spreadsheet_data.json', { month: month, year: year })
    data_totals = data['totals']
    performance = data_totals['internal_hours_billable'].to_f / data_totals['internal_hours_worked'].to_f

    performance.round(2)
  end

  def hours_worked(month, year)
    data = fetch('/api/monthly_salaries/spreadsheet_data.json', { month: month, year: year })
    data_totals = data['totals']
    data_totals['internal_hours_worked'].to_i
  end

  def commute_distances
    Geocoder.configure(units: :km, cache: Redis.new)

    user_addresses.map { |address|
      Geocoder::Calculations.distance_between(address, office_address)
    }.sort
  end

  def commute_durations
    user_addresses.map { |address|
      PublicTransport.connection_duration(address, office_address)
    }.sort
  end

  def office_address
    @office_address ||=
      begin
        data = fetch('/api/system_settings.json')
        data = data.find { |entry| entry['name'] == 'tenant' }['options']

        "#{data['address']}, #{data['zip']} #{data['city']}"
      end
  end

  private

  def user_data(filters = {})
    @user_data ||=
      begin
        fetch('/api/users.json').select { |user| user['active'] }
      end

    filters.inject(@user_data) do |user_data, filter|
      user_data = user_data.select { |user| user[filter[0].to_s] == filter[1] }
    end
  end

  def user_addresses
    @user_addresses ||=
      begin
        user_data(employment: 'employee')
          .map { |user|
            if user['address']
              user['address'].gsub(/[\n\r]+/, ', ')
            end
          }
          .compact
      end
  end

  def fetch(url, params = {})
    url = API_ENDPOINT + url
    params = params.merge(user_token: ENV['CONTROLLR_TOKEN'])

    JsonApi.fetch(url, params)
  end
end
