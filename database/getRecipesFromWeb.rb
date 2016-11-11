require 'nokogiri'
require 'open-uri'
require 'csv'

class String
  def rchomp(sep = $/)
    self.start_with?(sep) ? self[sep.size..-1] : self
  end
end

doc = Nokogiri::HTML(open("http://www.food.com/ideas/home-cook-food-pictures-6353?c=23334"))
container = doc.xpath('//div[@class="cards-inner"]')
links = container.xpath('//div[@class="fd-card  "]//@data-url').to_a
csv = CSV.open("recipes_potatos.csv", "a+")	

i = 0	
links.each do |link|	
	i += 1
	page = Nokogiri::HTML(open(link))
	title = page.xpath('//header[@class="recipe"]//h1').text
	ingredients = page.xpath('//div[@data-module="ingredients"]//ul').text.split("\n")
	ingredients.map! { |ingredient| ingredient.gsub(/ +/, ' ')}
	ingredients.map! { |ingredient| ingredient.gsub(/^ /, '')}
	ingredients = ingredients.reject { |ingredient| ingredient.empty? }
	ingredients = ingredients.reject { |ingredient| ingredient =~ /(optional)/ }
	ingredients = ingredients.join("\n")
	directions = page.xpath('//div[@data-module="recipeDirections"]/ol/li')
	directions.pop
	directions = directions.text
	
	csv << [title.to_s, ingredients.to_s, directions.to_s]
end


