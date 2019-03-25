#!/usr/bin/env ruby

require 'nokogiri'
require 'csv'
require 'byebug'
require 'json'

output = [['id', 'title', 'bibtext', 'publisher', 'date', 'count', 'unit']]

doc = File.open('source/a.html') { |f| Nokogiri::HTML(f) }
items = doc.xpath('//*[local-name() = "hr" or local-name() = "table"]/following-sibling::*[1][local-name() = "p"]')


items.each do |item|
    title = item.xpath('normalize-space(.//cite//text())')
    bib = item.xpath('normalize-space(./text())')
    bib = bib.gsub('--', ' -- ').gsub(/\ +/, ' ')
    puts bib
    parts = /([^\ ]+)\. \-\- ([\[\]0-9+\?]+) (microfilm reel|microfiche)/.match(bib)
    if parts then
        puts '  year: ' + parts.captures[0].gsub(/[^0-9]/, '').to_i.to_s
        puts '  ' + parts.captures.to_json if parts
    end
end

CSV.open('microforms.csv', 'w') do |csv_object|
  output.each do |row_array|
    csv_object << row_array
  end
end
