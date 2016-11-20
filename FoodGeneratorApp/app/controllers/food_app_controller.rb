class FoodAppController < ActionController::Base

	@@recipes = Rails.configuration.recipes
	@@relationships = Rails.configuration.relationships
	@@ingredients = Rails.configuration.ingredients	
		



	@@recipes_found = []
	@ingredients_prep = {}
	@visible_recipe = 0
	@relationships_matched = 0
	@@all_ingredients = 0


	def retriveIngredients()
		ingredients = @@ingredients.search('ingredient_name:' + params[:ingredientHolder]).to_a.map(&:to_hash)	
		render :json => ingredients
	end	
	
	def search_recipes
		ingredients = params[:ingredients_list]
		ingredients_string = "all_ingredients:("
		ingredients.each do |i|
			ingredients_string << i.to_s.gsub('+', '_').gsub('-', '_')
			ingredients_string << " AND "
		end

		ingredients_string = ingredients_string[0..ingredients_string.length - 6]
		ingredients_string << ")"
		puts ingredients_string
		@@recipes_found = @@recipes.search(ingredients_string).to_a.map(&:to_hash)
	
		render :json => @@recipes_found
	end

	def recipeDetailedView
		@@recipes_found.each do | recipe |
			if recipe['id'] == params[:id]
				@visible_recipe = recipe
				break
			end
		end

		@relationships_matched = @@relationships.search('recipe_id:' + params[:id]).to_a.map(&:to_hash)	
		render 'recipe'
	end

	def getAllIngredients
		@@all_ingredients = @@ingredients.search('*', {size: 1000} ).to_a.map(&:to_hash)	
		
		puts
		puts @@all_ingredients.length
		render json: @@all_ingredients
	end

end
