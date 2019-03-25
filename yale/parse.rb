#!/usr/bin/env ruby

require 'nokogiri'
require 'csv'
require 'byebug'

output = [['id', 'title', 'bibtext', 'publisher', 'date', 'count', 'unit']]

doc = File.open('microfilmlist-clean.html') { |f| Nokogiri::HTML(f) }
blocks = doc.xpath('//dl[dt/a]')
blocks.each do |block|

  header = block.xpath('./dt[1]')

  anchor = header.xpath('.//a[1]').first
  id = anchor.xpath('./@id').first.text if anchor
  title = anchor.text if anchor
  puts id + ': ' + title

  bib = header.xpath('text() | span/text()')
  bibtext = bib.last.text if bib.count > 0
  bibtext = '' unless bibtext

  # parse bib into publisher, date, count, unit
  # e.g. (Marlboro, Wiltshire, England: Adam Matthew Publications, 1998. 191 reels)

  bibregex = /\s?\(?(.*)[,;]\s?(.*)\.\s?(.*)\s(\w*)/
  parts = bibtext.match(bibregex) if bibtext != ''
  if parts then
    parts = parts.captures
  else
    # check for simple reel count
    bibregex2 = /\s?\(?(.*)\s(\w*)\)?/
    parts = bibtext.match(bibregex2) if bibtext != ''
    if parts then
      parts = ['', ''] + parts.captures
    else
      parts = ['','','','']
    end
  end
  publisher, date, count, unit = parts 
  description = block.xpath('./dd[1]')
  guide = block.xpath('./dt[2]')
  pubguide = block.xpath('./dt[3]')

  output << [id, title, bibtext, publisher, date, count.gsub(',', '').to_i, unit]

end

CSV.open('microforms.csv', 'w') do |csv_object|
  output.each do |row_array|
    csv_object << row_array
  end
end
