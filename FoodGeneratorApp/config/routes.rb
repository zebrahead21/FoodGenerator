Rails.application.routes.draw do
  # get '/main_page' => 'food_app#main_page'
  get '/ingredient' => 'food_app#ingredient'
  post '/putting_ingredient' => 'food_app#putting_ingredient'
  


end
