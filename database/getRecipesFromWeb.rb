require 'nokogiri'
require 'open-uri'
require 'csv'



=begin
#cantitatile in ordine
ingredientsQuantities = page.xpath('//div[@data-module="ingredients"]//ul//li//span').to_a
ingredientsQuantities.map! { |quantity| quantity.text}
puts ingredientsQuantities

=begin (STERG H4)
ingredientsUnitsRaw = page.xpath('//div[@data-module="ingredients"]//ul//li')
ingredientsUnitsRaw.search('.//h4').remove
#puts ingredientsUnitsRaw
=end (STERG H4)

=begin
unitatile de masura a ingredientelor in stadiul final pentru reteta curenta
ingredientsUnitsUniq = ingredientsUnitsUniq - blackSheepIngredients
=end

#puts ingredientsListRawXML

#Retrive quantities with units 
#ingredientsListRaw.xpath('./li[./span[not(text())]]').remove
#ingredientsQuantities = ingredientsListRaw


#puts ingredientsListRaw
=begin
ingredientsQuantities = ingredientsListRaw.xpath('./li/span').to_a
ingredientsQuantities.map! { |quantity| quantity.text }
ingredientsUnits = ingredientsListRaw.xpath('./li/text()').to_a
ingredientsUnits.map! { |unit| unit.to_s.gsub(/^ */,'')}
ingredientsUnits = ingredientsUnits.select {|unit| unit =~ /^[ a-z]/ or unit == ''}

puts ingredientsListRaw
##################################################################

# trebuie sa zipuiesti ingredientsUnits cu ingredientsQuantities !!!!!

#Retrive data ingredient attribute from li
ingredientsWithQuantitiesDataIngredientID = ingredientsListRaw.xpath('./li/@data-ingredient')
ingredientsWithQuantitiesDataIngredientID.map { |attr|
	attr.value
}.compact

#puts "INGREDIENTS UNITS:"
#puts ingredientsUnits
#puts "INGREDIENTS QUANTITIES"
#puts ingredientsQuantities
#puts "INGREDIENTS WITH QUANTITIES DATA INGREDIENT ID:"
#puts ingredientsWithQuantitiesDataIngredientID

####################################################################


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

#puts "BLACKSHEEP INGREDIENTS:"
#puts blackSheepIngredients
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
#puts ingredientsInfoBeforeCooking
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

#puts "INGREDIENTS INFO BEFORE COOKING:"
#puts ingredientsInfoBeforeCooking
#########################################################




###################################################################
=end

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

links.each do |link|	
	
	###############################################################	
	# Aici se creeaza csv-ul cu relatii intre retete si ingrediente
	# Se va face un array de hash-uri relationshipRecipesIngredients
	###############################################################

	recipeID = link.to_s.gsub("http://www.food.com/recipe/", '')
	
	page = Nokogiri::HTML(open(link))
	ingredientsListRaw = page.xpath('//div[@data-module="ingredients"]//ul')

	dataIngredientIDs = ingredientsListRaw.xpath('.//li//@data-ingredient').to_a

	ingredientsListRaw.search('./li/h4').remove
	ingredientsListRaw.xpath('.//li').each do |item|
		if item.xpath('.//span[not(text())]')
			item.replace item.content
		end
	end
	
	ingredientsListRaw = ingredientsListRaw.text().split("\n").reject! {|item| item.empty?}
	ingredientsListRaw.each do |item|
		item = item.gsub!(/^ */, '').gsub!(/\s+/, " ")
	end

	i = 0
	ingredientsListRaw.each do |item|
		relationshipRecipeIngredient = {}
		hasQuantity = 0
		if item =~ /^[0-9]+[\u{2044}]?[0-9]* /
			quantity = item[/^[0-9]+[\u{2044}]?[0-9]* /]
			item[/^[0-9]+[\u{2044}]?[0-9]* /] = ''
			relationshipRecipeIngredient["quantity"] = quantity.strip
			hasQuantity = 1
		else
			relationshipRecipeIngredient["quantity"] = ""
		end
	
		if item =~ /^[a-z]+ +/ and hasQuantity == 1
			units = item[/^[a-z]+ +/]
			item[/^[a-z]+ +/] = ''
			relationshipRecipeIngredient["units"] = units.strip
		else
			relationshipRecipeIngredient["units"] = ""
		end

		if item =~ /^[a-z -]*,?/
			description = item[/^[a-z -]*,?/]
			item[/^[a-z -]*,?/] = ''
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
		if item.xpath('.//span[not(text())]')
			item.replace item.content
		end
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
infoAboutRecipes.to_csv("recipes.csv")
