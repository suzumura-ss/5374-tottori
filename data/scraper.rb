require 'rest-client'
require 'nokogiri'

html = RestClient.get('http://www.city.tottori.lg.jp/www/contents/1357776059978/index.html')
dom = Nokogiri::HTML.parse(html, nil, 'utf-8')
puts dom.xpath("//tbody")[1].xpath("tr").map{|tr|
  # [" わ", "若桜町", "月・木", "木", "金", "第１・３木", "第４木", "２４"]
  elem = tr.xpath("td").map{|_|
    _.text.gsub(/[ \r\n]*/, '').gsub(/[第・]/, '').tr("０１２３４５６７８９", '0123456789')
  }.map{|_|
    case _
    when %r{\A(\d+)([日月火水木金土])\z}
      d = $2
      $1.scan(/./).map{|i|
        "#{d}#{i}"
      }.join(' ')
    when %r{\A([日月火水木金土]+)\z}
      $1.scan(/./).join(' ')
    else
      _
    end
  }
}.map{|_|
  # 南安長,,*1 月 木,*2 木,*2 火,*2 火,*2 火,*2 木2 木4,*2 月2,*2 火1:2 4 6 8 10 12
  _[0] = _[1]
  _[1] = ""
  [_[0..4], _[4], _[4..-2], "火1:2 4 6 8 10 12"].flatten
}.map{|_|
  _.map.each_with_index{|_,i|
    case i
    when 0, 1
      _
    when 2
      "*1 #{_}"
    else
      "*2 #{_}"
    end
  }
}.select{|_| _[0]!="可燃ごみ"}.map{|_|
  _.join(',')
}.join("\n")
