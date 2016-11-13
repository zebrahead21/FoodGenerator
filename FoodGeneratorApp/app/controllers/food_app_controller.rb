class FoodAppController < ActionController::Base
	# @@recipes = Rails.configuration.recipes
	# @@relationships = Rails.configuration.relationships
	

	def main_page

	end

	def ingredient
		# @item = @@ingredient.find(params[:id].to_i).to_hash
		

		
		render :json => session[:ingredient]

	end

	def putting_ingredient

		session[:ingredient] << params[:ingredient]
		

		render :json => session[:ingredient]
	end


	





end