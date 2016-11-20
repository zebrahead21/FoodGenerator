class FoodAppController < ActionController::Base

	@@recipes = Rails.configuration.recipes
	@@relationships = Rails.configuration.relationships
	@@ingredients = Rails.configuration.ingredients	
		




	def retriveIngredients()
		ingredients = @@ingredients.search('ingredient_name:' + params[:ingredientHolder]).to_a.map(&:to_hash)	
		render :json => ingredients
	end	
	

	def putting_ingredient
		session[:ingredients] ||= []
		session[:ingredients] << params[:ingredient_name]
		puts
		puts session[:ingredients]
		puts
		render :json => session[:ingredients]
	end


	def search_recipes

		ingredients = params[:ingredients_list]
		# puts
		# puts
		# puts
		# puts
		# puts "da"
		# puts ingredients
		# puts
		# puts
		# puts
		# puts
		# puts
		ingredients_string = "all_ingredients:("
		ingredients.each do |i|
			ingredients_string << i.to_s.gsub('+', '_').gsub('-', '_')
			ingredients_string << " AND "
		end

		ingredients_string = ingredients_string[0..ingredients_string.length - 6]
		ingredients_string << ")"
		puts ingredients_string
		recipes_found = @@recipes.search(ingredients_string).to_a.map(&:to_hash)
		# puts
		# puts
		# puts
		# puts
		# puts "nu"
		# puts recipes_found
		# puts
		# puts
		# puts
		# puts 
		render :json => recipes_found
	end

end
