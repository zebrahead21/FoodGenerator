require 'nokogiri'
require 'open-uri'

PAGE_URL = "https://ndb.nal.usda.gov/ndb/search/list?ds=Standard+Reference"
MAX_PAGE = 176

index = 0
output = []

while index <= MAX_PAGE do
  offset = '&offset=' + (index * 50).to_s
  index += 1

  doc = Nokogiri::HTML(open(PAGE_URL + offset, "User-Agent" => "Mozilla Firefox"))

  doc.css("tr").each do |tr|
    info_array = tr.css('td a').map(&:content).map(&:strip).to_a

    if info_array == []
    	next
    end

    output << info_array
  end

end

open('national_nutrient_database.csv', 'w') { |f|
  output.each { |output_info|
  	f.puts output_info[0].to_s + " | " + output_info[1].to_s
  }
}
