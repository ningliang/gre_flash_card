require 'rubygems'
require 'net/http'
require 'hpricot'
require 'json'

words = []
('a'..'z').each do |letter|
  url = URI.parse("http://www.wordhacker.com/en/article/Barron_gre_list_#{letter}.htm")
  
  request = Net::HTTP::Get.new(url.path)
  request.add_field("User-Agent", "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.1) Gecko/20090624 Firefox/3.5")
  
  response = Net::HTTP.new(url.host, url.port).start do |http| http.request(request) end
  
 
  doc = Hpricot::XML(response.body)
  elements = doc.search("/html/body/div/table[4]/tbody/tr/td[2]/table/TBODY/TR/TD/table/tr")
  elements.each do |element|
    row = Hpricot::XML(element.inner_html)
    items = row.search("td")
    if (items.length > 1) 
      word = items[0].inner_html.strip.gsub(/\s+/, " ")
      definition = items[1].inner_html.strip.gsub(/\s+/, " ")
      words.push({ "word" => word, "definition" => definition })
    end
  end
end

puts words.to_json