# coding: utf-8
require 'bundler/setup'
require 'open-uri'
require 'kconv'
Bundler.require


def GetImages(pref,shop)
  #default
  url = 'http://www.yorkbeni.co.jp/store/fukusima/'
  
  if pref == "福島"
    url = 'http://www.yorkbeni.co.jp/store/fukusima/'
  elsif pref == "宮城"
    url = 'http://www.yorkbeni.co.jp/store/miyagi/'
  elsif pref == "山形"
    url = 'http://www.yorkbeni.co.jp/store/yamagata/'
  elsif pref == "栃木"
    url = 'http://www.yorkbeni.co.jp/store/tochigi/'
  elsif pref == "茨城"
    url = 'http://www.yorkbeni.co.jp/store/ibaraki/'
  end
  pref = 'index.html'
  charset = nil
  html = open(url+pref) do |f|
    charset = f.charset
    f.read
  end
  doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')
  str = ""
  shop = Regexp.new(shop)
  node = doc.css('td').each do |line|
    if line.text =~ shop
      str = line.inner_html.to_s
    end
  end
  ur = str.match(/([a-z]*).html/).to_s
  puts ur

  charset = nil
  html = open(url+ur) do |f|
    charset = f.charset
    f.read
  end
  doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

  node = doc.css('tr').each do |line|
    if line.inner_html =~ /チラシ/
      str = line.inner_html.to_s
    end
  end
  ur = str.match(/https(.*)auto/).to_s

  charset = nil
  html = open(ur) do |f|
    charset = f.charset
    f.read
  end
  doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')  
  node = doc.css('td').each do |line|
    if line.text =~ /JPEG/
      str = line.inner_html.to_s
    end
    
  end

  image = str.match(/https(.*)1.jpg/).to_s
  image2 = Marshal.load(Marshal.dump(image))
  if image2.nil?
    image2[-5] = "2"
  end

  if !image.nil? && !image2.nil?
    return "chirashi","not"
  else
    return image,image2
  end
end
