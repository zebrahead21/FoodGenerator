require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open("http://www.food.com/recipe/weight-watchers-deep-dish-pizza-casserole-224261?scaleto=6.0&st=null&mode=us"))


puts ingredientsListRaw
#puts dataIngredientLiAttribute
