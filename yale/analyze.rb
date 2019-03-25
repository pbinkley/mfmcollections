#!/usr/bin/env ruby

require 'nokogiri'
require 'csv'
require 'json'
require 'byebug'

frames = {reels: 1000, fiches: 100}
input = CSV.read('microforms-clean.csv', headers: true)

framecount = 0
formats = {}
years = {}

input.each do |row|
  format = row['unit']
  if format != nil
    format.downcase!
    format = 'fiches' if format == 'microfiches' or format == 'fiche'
    format = format.to_sym
    formats[format] = 0 unless formats[format]
    formats[format] += row['count'].to_i

    framecount += row['count'].to_i * frames[format] if frames[format]
  end
  rawdate = row['date']
  if rawdate
    rawdate = rawdate.gsub(/[^0-9\-]/, '')
    if rawdate.include? '-'
      # handle the dash at beginning of string - should be at end
      if rawdate[0] == '-'
        rawdate = rawdate[1..rawdate.length] + '-'
      end
    end
    dates = rawdate.split '-'
    dates.map! { |d| d.to_i }
    # if rawdate ends with dash, set last year to 2006
    #dates[1] = 2006 unless dates[1]
    dates[1] = dates[0]+5 unless dates[1] unless dates[1]
    # dates is now an array of year strings: start and end (end may be nil)
    dates[1] = dates[0] unless dates[1] # end year is same as start year
    framecount = row['count'].to_i * frames[format] if frames[format]
    if framecount
      yearcount = dates[1] - dates[0] + 1
      yearframes = 0
      yearframes = ((row['count'].to_i / yearcount) * frames[format]).round if frames[format]
      (dates[0]..dates[1]).each do |year|
        years[year] = 0 unless years[year]
        years[year] += yearframes 
      end
    end
  end 
end

puts formats
puts framecount
years.keys.sort.each do |year|
  puts year.to_s + ': ' + years[year].to_s
end