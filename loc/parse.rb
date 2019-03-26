#!/usr/bin/env ruby

require 'nokogiri'
require 'csv'
require 'byebug'
require 'json'

output = [['id', 'title', 'bibtext', 'publisher', 'date', 'count', 'unit']]
files = ['a','b','c','d','e','f','g','h','i','j','kl','m','n','o','pq','r','s','t','u','v','w','xz']

report = {parsed: 0, unparsed: 0}

files.each do |file|
  counter = 1
  
  doc = File.open('source/' + file + '.html') { |f| Nokogiri::HTML(f) }
  items = doc.xpath('//*[local-name() = "hr" or local-name() = "table"]/following-sibling::*[1][local-name() = "p"]')
  
  
  items.each do |item|
    id = file + counter.to_s
      title = item.xpath('normalize-space(.//cite//text())')
      bib = item.xpath('normalize-space(./text()[last()])')
      bib = bib.gsub('--', ' -- ').gsub(/\ +/, ' ')
      r = /[ \-\.]*(.+?) ([^\ ]+)\ ?\.? (\-\- )?(ca\. )?([\[\]<>0-9+\?,]+) (microfilm reel|microfiche|microopaque)/
      parts = r.match(bib)
      unless parts then
            # look for unit without count
        # e.g. -- Washington, D.C. : Congressional Information Service, [1974]- . -- [ ] microfiches; 11 x 15 cm.
        # or / dirección y redacción Victor Herrero Mediavilla. [München ; New York : K.G. Saur. -- microfiche : negative.
        r = /[ \-\.]*(.+?) ([^\ ]+)\ ?\.? (\-\-)?( ca\.)?( [\[<] ?[\]>])? (microfilm reel|microfiche|microopaque)/
        parts = r.match(bib)
      end
      if parts then
          # puts '  year: ' + parts.captures[0].gsub(/[^0-9]/, '').to_i.to_s
          puts '  ' + parts.captures.to_json if parts
          report[:parsed] += 1
      else
        puts '* ' + title
        puts bib
        report[:unparsed] += 1
      end
  #    byebug if title == 'The Artists file'
    counter += 1
  end
end

puts 'parsed: ' + report[:parsed].to_s + '; unparsed: ' + report[:unparsed].to_s

CSV.open('microforms.csv', 'w') do |csv_object|
  output.each do |row_array|
    csv_object << row_array
  end
end
