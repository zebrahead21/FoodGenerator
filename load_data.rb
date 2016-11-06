require 'elasticsearch/persistence'
require 'digest'
require 'csv'


class DataRecord
  attr_reader :attributes

  def initialize(attributes={})
    @attributes = attributes
  end

  def to_hash
    @attributes
  end
end


  recipes = Elasticsearch::Persistence::Repository.new do
    client Elasticsearch::Client.new url: 'http://localhost:9200', log: true
    index :recipes
    type  :data_record
  end
  recipes.create_index! force: true

  ingredients = Elasticsearch::Persistence::Repository.new do
    client Elasticsearch::Client.new url: 'http://localhost:9200', log: true
    index :ingredients
    type  :data_record
  end
  ingredients.create_index! force: true

  r_id_relationships = Elasticsearch::Persistence::Repository.new do
    client Elasticsearch::Client.new url: 'http://localhost:9200', log: true
    index :r_id_relationships
    type  :data_record
  end
  r_id_relationships.create_index! force: true



  	CSV.read('/home/camelia/Projects/WebDev/recipes.csv').each do |current_recipe_list|
		current_recipe_id = Digest::SHA256.hexdigest(current_recipe_list[0])
		recipes.save(
      	{ id: current_recipe_id, recipes_description: current_recipe_list[0] }
    	)
	end

	CSV.read('/home/camelia/Projects/WebDev/ingredients.csv').each do |current_ingredient_list|
		current_ingredient_id = Digest::SHA256.hexdigest(current_ingredient_list[0])
		ingredients.save(
      	{ id: current_ingredient_id, recipes_description: current_ingredient_list[0] }
    	)
	end

	CSV.read('/home/camelia/Projects/WebDev/ingredient_recipes_relationships.csv').each do |i_r_rel_list|
		line = i_r_rel_list[0]
		i_r_rel_id = Digest::SHA256.hexdigest(line)
		after_split = line.split('|')
		i_id = Digest::SHA256.hexdigest(after_split[0])
		r_id = Digest::SHA256.hexdigest(after_split[1])
		r_id_relationships.save(
		{ id: i_r_rel_id, recipe_id: r_id, ingredient_id: i_id }
		)

	end
    





