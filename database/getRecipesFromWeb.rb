require 'nokogiri'
require 'open-uri'
require 'csv'

#Extrag elementele atipice din lista de ingrediente

blackSheepIngredients = ingredientsListRawXML
blackSheepIngredients.xpath('.//h4').remove
blackSheepIngredients.css('li').each do |li|
	if li.at_css('a')
		li.remove
	end
end

blackSheepIngredients = blackSheepIngredients.css('li').text()
blackSheepIngredients.gsub!(/^ */, "")
blackSheepIngredients = blackSheepIngredients.split("\n")
blackSheepIngredients.reject! { |blacksheep| blacksheep.empty? }

###################################################################

#Retrive info about what to do with the ingredients before cooking
ingredientsInfoBeforeCooking = page.xpath('//div[@data-module="ingredients"]//ul') 
ingredientsInfoBeforeCooking.xpath('.//span').remove
ingredientsInfoBeforeCooking.xpath('.//h4').remove

ingredientsInfoBeforeCooking.css("a").each do |a|
	a.replace a.inner_html
end

ingredientsInfoBeforeCooking.css("li").each do |li|
	li.replace li.inner_html
end

ingredientsInfoBeforeCooking = ingredientsInfoBeforeCooking.text()
ingredientsInfoBeforeCooking.gsub!(/^[ \n] */, "")
ingredientsInfoBeforeCooking = ingredientsInfoBeforeCooking.split("\n")
ingredientsInfoBeforeCooking.reject! { |info| info.empty? }
ingredientsInfoBeforeCooking -= blackSheepIngredients
ingredientsInfoBeforeCooking.map! { |info| 
	if info =~ /^[a-z -]* \([a-z -]*\)$/
		info.gsub(/^[a-z -]* /, '').gsub(/^\(/, '').gsub(/\)$/, '')
	else
		if info =~ /^[a-z -]*, /
			info.gsub(/^[a-z -]*, /, '')
		else 
			""
		end
	end
}

#########################################################




###################################################################

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

csv = CSV.open("recipes_potatos.csv", "a+")	

relationshipRecipesIngredients = []
infoAboutRecipes = []
infoAboutIngredients = []

links.each do |link|	
	
	###############################################################	
	# Aici se creeaza csv-ul cu relatii intre retete si ingrediente
	# Se va face un array de hash-uri relationshipRecipesIngredients
	###############################################################

	recipeID = link.to_s.gsub("http://www.food.com/recipe/", '')
	
	page = Nokogiri::HTML(open(link))
	ingredientsListRaw = page.xpath('//div[@data-module="ingredients"]//ul')

	dataIngredientIDs = ingredientsListRaw.xpath('.//li//@data-ingredient').to_a
	urlKeyOfIngredients = ingredientsListRaw.xpath('.//li').to_a
	
	urlKeyOfIngredients.map! do |urlKey|
		if urlKey.xpath('.//a')
			urlKey.xpath('.//a//@href').to_s.gsub(/http:\/\/www.food.com\/about\//, '') 
		else
			""
		end
	end
	i = 0
	ingredient = {}
	dataIngredientIDs.each do |currentDataIngredientID|
		ingredient["urlkey"] = urlKeyOfIngredients[i]
		ingredient["dataingredient"] = currentDataIngredientID.to_s	
		ingredient["description"] = currentDataIngredientID.to_s.gsub(/\+/,' ')
		i = i + 1
	end
	infoAboutIngredients.push(ingredient)	
	
	ingredientsListRaw.search('./li/h4').remove
	ingredientsListRaw.xpath('.//li').each do |item|
		if item.xpath('.//a')
			item.xpath('.//a').each do |a|
				a.content = "_" + a.content + "_"				
			end
		end

	end

	ingredientsListRaw.xpath('.//li').each do |item|
		item.replace item.content
	end
	
	ingredientsListRaw = ingredientsListRaw.text().split("\n").reject! {|item| item.empty?}
	ingredientsListRaw.each do |item|
		item = item.gsub!(/^ */, '').gsub!(/\s+/, " ")
	end

	i = 0
	ingredientsListRaw.each do |item|
		relationshipRecipeIngredient = {}
		hasQuantity = 0
		if item =~ /^[0-9 ]*[\u{2044}]?[0-9 ] * /
			quantity = item[/^[0-9 ]*[\u{2044}]*[0-9 ]* /]
			item[/^[0-9 ]*[\u{2044}]*[0-9 ]*/] = ''
			relationshipRecipeIngredient["quantity"] = quantity.strip
			hasQuantity = 1
		else
			relationshipRecipeIngredient["quantity"] = ""
		end
	
		if item =~ /^[a-z]+ / and hasQuantity == 1
			units = item[/^[a-z]+ / ]
			item[/^[a-z]+ /] = ''
			relationshipRecipeIngredient["units"] = units.strip
		else
			relationshipRecipeIngredient["units"] = ""
		end

		if item =~ /^_[a-z -]*_,?/
			description = item[/^_[a-z -]*_,?/]
			item[/^_[a-z -]*_,?/] = ''
			
			if description =~ /,/ 
				description[/,/] = ''
			end
			
			description.gsub!('_', '')
			relationshipRecipeIngredient["description"] = description.strip
		end
	
		semipreparation = item
		relationshipRecipeIngredient["semipreparation"] = semipreparation
	
		if relationshipRecipeIngredient["description"] != ""
			relationshipRecipeIngredient["id"] = recipeID.to_s + "#" + dataIngredientIDs[i].to_s
			relationshipRecipesIngredients.push(relationshipRecipeIngredient)
		end
	
		i = i + 1
	end	
	
	##############################################################################################
	# Incheierea crearii arrayului de hashuri ce va fi scris in csv-ul cu relatii recipe-ingredient
	##############################################################################################

	##############################################################################################
	# Crearea csv-ului cu informatii despre retete
	##############################################################################################

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
