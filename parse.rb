require 'open-uri'
require 'nokogiri'


def getpage(url, code)
  filename = "cache/#{code}.htm"
  if File.exist? "cache/#{code}.htm"
    content = IO.read filename
  else
    begin
      page = open(url)
      content = page.read
      File.open(filename, 'w') {|f| f.write(content) }
    rescue
    end
  end
  content
end

# очистить файл
File.open('out.txt', 'w') {|f| f.write '' }
File.open('schools.txt', 'w') {|f| f.write '' }

cities = {}
cities_raw = IO.read 'cities.txt'
cities_raw.split("\n").each do |line|
  code, city = line.split("\t")
  cities[code.chomp] = city.chomp
end

allcities = {}

(10..89).each do |code|
  p code
  url = "http://www.gibdd.ru/r/#{code}/drivingscools/"
  content = getpage url, code
  doc = Nokogiri::HTML(content)

  city_count = 0
  area_count = 0

  allcities[code] = {}

  doc.css('li.scool-item').each do |school|
    addr_line = school.css('.scool-addr').text.split(': ',0)

    city = cities["#{code}"]

    #p '-------------'
    #p addr_line[1]
    #p "г. #{city}"

    if addr_line[1].include?("г. #{city}") || addr_line[1].include?("г.#{city}") || addr_line[1].include?("город #{city}")
      city_count+=1
      #p 'ok'
    else
      #p 'no'
      area_count+=1
    end

    addr = addr_line[1].split(',').map { |s| s.strip }

    #p "#{code}|#{city}|#{area}|#{addr[0]}|#{addr[1]}"

    allcities[code][school.css('.scool-name').text] = {
        rekv: school.css('.scool-rekv').text,
        addr: school.css('.scool-addr').text,
        tel:  school.css('.scool-tel').text,
        region: code
    }

    File.open('schools.txt', 'a') {|f|
      f.write school.css('.scool-name').text + "\t"
      f.write school.css('.scool-rekv').text + "\t"
      f.write school.css('.scool-tel').text + "\t"
      f.write "#{code}" + "\t"
      f.write school.css('.scool-addr').text + "\t"
      f.write "\n"
    }

  end

  desc = doc.css('body #wrapper #container #content > p').text
  all = 0
  if m = /\(всего (\d+)\)/.match(desc)
    all = m[1]
  end

  File.open('out.txt', 'a') {|f| f.write  "#{code}\t#{city_count}\t#{area_count}\t#{all}\n" }


end






