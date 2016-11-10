# URLにアクセスするためのライブラリの読み込み
require 'open-uri'
# Nokogiriライブラリの読み込み
require 'nokogiri'

def getTime(doc, hour, minutes, is_skip = false)
  hour_tr = doc.css('.tblDiaDetail > #hh_' + hour.to_s)
  next_min = nil

  hour_tr.css('.timeNumb').search('dt').each do |m|

    min = m.inner_text.to_i
    if min < minutes + 5
      next
    end
    next_min = min
    if !is_skip
      break
    else
      is_skip = false
    end

  end

  next_hour = hour
  if next_min == nil
    next_next= getTime(doc, next_hour + 1, 0)
    next_hour = next_next[0]
    next_min = next_next[1]
  end
  return [next_hour, next_min]
end

## 次の次はスキップする
is_skip = ARGV[0] != nil

#曜日も気にしなくては
now = Time.now
hour = now.hour
minutes = now.min
w_day = now.wday
# スクレイピング先のURL
if w_day == 7
  url = "http://transit.yahoo.co.jp/station/time/23246/?kind=4&gid=1180"
elsif w_day == 6
  url = "http://transit.yahoo.co.jp/station/time/23246/?kind=2&gid=1180"
else
  url = "http://transit.yahoo.co.jp/station/time/23246/?gid=1180"
end
charset = nil
html = open(url) do |f|
  charset = f.charset # 文字種別を取得
  f.read # htmlを読み込んで変数htmlに渡す
end

# htmlをパース(解析)してオブジェクトを生成
doc = Nokogiri::HTML.parse(html, nil, charset)
next_time = getTime(doc, hour, minutes, is_skip)
next_train = Time.new(now.year, now.month, now.day, next_time[0], next_time[1], 0, "+09:00")

puts "次の電車は" + next_time[0].to_s + "時" + next_time[1].to_s + "分に出ます。"
puts  "あと" + ((next_train - now) / 60).to_i.to_s + "分で発車します"

