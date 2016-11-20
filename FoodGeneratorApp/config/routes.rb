Rails.application.routes.draw do
  get '/main_page' => 'food_app#main_page'
  get '/ingredientsThatMatchIngredientHolder.json' => 'food_app#retriveIngredients'
  get '/recipe/:id' => 'food_app#recipeDetailedView'

  post '/getIngredientsList' => 'food_app#search_recipes'

end
