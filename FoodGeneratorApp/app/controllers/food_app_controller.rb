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

end
