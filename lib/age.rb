class Age
  def self.from_date(date_of_birth)
    now = Time.now.utc.to_date

    leap_year_correction =
      if now.month > date_of_birth.month ||
        (now.month == date_of_birth.month && now.day >= date_of_birth.day)
        0
      else
        1
      end

    now.year - date_of_birth.year - leap_year_correction
  end
end
