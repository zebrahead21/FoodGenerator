require 'nokogiri'
require 'open-uri'
require 'csv'

class Array
  def to_csv(csv_filename="hash.csv")
    require 'csv'
    CSV.open(csv_filename, "wb", {:col_sep => "|"}) do |csv|
      self.each do |hash|
        csv << hash.values
      end
    end
  end
end

doc = Nokogiri::HTML(open("http://www.food.com/ideas/favorite-weight-watcher-recipes-6010"))
container = doc.xpath('//div[@class="cards-inner"]')
links = container.xpath('//div[@class="fd-card  "]//@data-url').to_a

relationshipRecipesIngredients = []
infoAboutRecipes = []
infoAboutIngredients = []
links.each do |link|	

	####################
	# Mai intai creez fisierul ingredients.csv + relationships.csv
	##########################################

	recipeID = link.to_s.gsub("http://www.food.com/recipe/", '')
	page = Nokogiri::HTML(open(link))
	ingredientsListRaw = page.xpath('//div[@data-module="ingredients"]//ul//li')

	dataIngredientIDs = ingredientsListRaw.xpath('.//@data-ingredient').to_a
	
	urlKeyOfIngredients = ingredientsListRaw.to_a
	
	urlKeyOfIngredients.map! do |urlKey|
		if urlKey.xpath('.//a')
			urlKey.xpath('.//a//@href').to_s.gsub(/http:\/\/www.food.com\/about\//, '') 
		else
			""
		end
	end	

	ingredientsListRaw = ingredientsListRaw.to_a
	ingredientsListRaw.map! { |ingredient| 
			ingredient.content.to_s.gsub(/ +/, ' ').gsub(/^ /, '') 
	}
		

	i = 0

	dataIngredientIDs.each do |currentDataIngredientID|
		
		ingredient = {}
		relationship = {}
		ingredient["urlkey"] = urlKeyOfIngredients[i]
		ingredient["dataingredient"] = currentDataIngredientID.to_s	
		ingredient["description"] = currentDataIngredientID.to_s.gsub(/\+/,' ')
		infoAboutIngredients.push(ingredient)
		relationship['ingredientname'] = currentDataIngredientID.to_s.gsub(/\+/,' ')
		relationship['text'] = ingredientsListRaw[i]	
		relationship['id'] = recipeID.to_s + "#" + currentDataIngredientID.to_s		
		relationshipRecipesIngredients.push(relationship)
		i = i + 1
	end

	page = Nokogiri::HTML(open(link))
	infoAboutRecipe = {}
	infoAboutRecipe["id"] = recipeID
	infoAboutRecipe["name"] = page.xpath(".//header//h1").text()	

	directionsListRaw = page.xpath('.//div[@data-module="recipeDirections"]//ol')
	directionsListRaw.search('./li/div[@class="recipe-tools"]').remove
	directionsListRaw.xpath('.//li').each do |item|
			item.replace item.content
	end

	directionsListRaw = directionsListRaw.text().split("\n").reject! { |item| item.empty? }
	directionsListRaw.each do |item|
		item = item.gsub!(/^ */, '')
	end
	directionsListRaw.reject! { |item| item.empty?}
	directionsListRaw = directionsListRaw.join(" ")

	infoAboutRecipe["directions"] = directionsListRaw.to_s
	infoAboutRecipes.push(infoAboutRecipe)

end

relationshipRecipesIngredients.to_csv("relationships.csv")
infoAboutIngredients.to_csv("ingredients.csv")
infoAboutRecipes.to_csv("recipes.csv")	
