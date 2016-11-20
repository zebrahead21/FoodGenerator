Rails.application.routes.draw do
  get '/main_page' => 'food_app#main_page'
  get '/ingredientsThatMatchIngredientHolder.json' => 'food_app#retriveIngredients'

  post '/getIngredientsList' => 'food_app#search_recipes'
  

end
