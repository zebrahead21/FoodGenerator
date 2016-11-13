class FoodAppController < ActionController::Base
	# @@recipes = Rails.configuration.recipes
	# @@relationships = Rails.configuration.relationships
	


	def putting_ingredient
		session[:ingredients] ||= []
		session[:ingredients] << params[:ingredient_name]
		puts
		puts session[:ingredients]
		puts
		render :json => session[:ingredients]
	end


	





end