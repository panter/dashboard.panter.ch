# Overwrite dashing's filter
# (original in `javascripts/dashing.coffee`)
#
# Numbers starting at 100'000 are already
# represented as million (i.e. 0.1M). Dashing's
# original left them up to 1'000'000.
Batman.Filters.shortenedNumber = (num) ->
  return num if isNaN(num)
  if num >= 1000000000
    (num / 1000000000).toFixed(1) + 'B'
  else if num >= 100000
    (num / 1000000).toFixed(1) + 'M'
  else if num >= 1000
    (num / 1000).toFixed(1) + 'K'
  else
    num
