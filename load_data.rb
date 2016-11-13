require 'digest'
require 'csv'
require 'elasticsearch/persistence'


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

# ingredients = Elasticsearch::Persistence::Repository.new do
#   client Elasticsearch::Client.new url: 'http://localhost:9200', log: true
#   index :ingredients
#   type  :data_record
# end
# ingredients.create_index! force: true

relationships = Elasticsearch::Persistence::Repository.new do
  client Elasticsearch::Client.new url: 'http://localhost:9200', log: true
  index :relationships
  type  :data_record
end
relationships.create_index! force: true


CSV.read('database/recipes.csv',
  {:col_sep => '|'}).map { |row| recipes.save({ 
                                        'key': row[0], 
                                        'descr': row[1], 
                                        'preparation': row[2] }) }

# CSV.read('testing_csv/ingredients_test.csv',
#   {:col_sep => '|'}).map { |row| ingredients.save({ 
#                                         'data_ingredient_id': row[0], 
#                                         'url_key': row[1], 
#                                         'description': row[2] }) }

CSV.read('database/relationships.csv',
  {:col_sep => '|'}).map { |row| relationships.save({ 
                                        'id': Digest::SHA256.hexdigest(row[4]), 
                                        'quantity': row[0], 
                                        'unit_measure': row[1],
                                        'semi_preparation': row[3],
                                        'structured_ingredient': row[2].gsub(/[,]/, '') }) }

 
	# CSV.read('/home/camelia/Projects/WebDev/FoodGenerator/testing_csv/ingredient_recipes_relationships.csv').each do |i_r_rel_list|
	# 	line = i_r_rel_list[1]
  #   puts line
  #   puts '............'
	# 	i_r_rel_id = Digest::SHA256.hexdigest(line)
	# 	after_split = line.split('|')
	# 	i_id = Digest::SHA256.hexdigest(after_split[0])
	# 	r_id = Digest::SHA256.hexdigest(after_split[1])
	# 	# r_id_relationships.save(
	# 	# { id: i_r_rel_id, recipe_id: r_id, ingredient_id: i_id }
	# 	# )

	# end
