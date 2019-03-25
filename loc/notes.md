- loc files captured from https://www.loc.gov/rr/microform/guide/index.html , 2019-03-24

entries look like

<p><cite><strong>Abolitionist periodicals</strong> </cite> -- Washington, 
              D.C. : Library of Congress Photoduplication Service, [1970?]. -- 
              [30] microfilm reels ; 35 mm. </p>
            <p>

and the follow a <table> (the first one) or an <hr>

So this xpath seems to work:

items = doc.xpath('//*[local-name() = "hr" or local-name() = "table"]/following-sibling::*[1][local-name() = "p"]')

title = item.xpath('normalize-space(.//cite//text())')
bib = item.xpath('normalize-space(./text())')

bib will need to have '--' replaced with ' -- ' and then normalized, since sometimes the space is missing

retrieve date, count, unit:

```
items.each do |item|
    parts = /([c0-9\-\?\ ]+)\. -- ([\[\]0-9+\?]+) (microfilm reel|microfiche)/.match(item.xpath('normalize-space(./text())'))
    if parts then
        parts[2] = parts[0].to_i
        puts parts.captures.to_json if parts
    end
end
```

Will need a fallback in case count is missing, e.g.:

```
editor, Laureen Baillie. -- Munchen: K. G. Saur Verlag, [1995?]. -- microfiche.
```

