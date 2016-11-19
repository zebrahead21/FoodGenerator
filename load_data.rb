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

ingredients = Elasticsearch::Persistence::Repository.new do
  client Elasticsearch::Client.new url: 'http://localhost:9200', log: true
  index :ingredients
  type  :data_record
end
ingredients.create_index! force: true

relationships = Elasticsearch::Persistence::Repository.new do
  client Elasticsearch::Client.new url: 'http://localhost:9200', log: true
  index :relationships
  type  :data_record
end
relationships.create_index! force: true

hashmap = {}  


CSV.read('database/relationships.csv',
  {:col_sep => '|'}).map { |row| hashmap[row[2].split('#')[0]] ||= []
                                 hashmap[row[2].split('#')[0]] << row[2].split('#')[1].gsub('+','_') 
                                 relationships.save({ 
                                        'id': Digest::SHA256.hexdigest(row[2]),
                                        'ingredient_id': row[2].split('#')[1], 
                                        'recipe_id': row[2].split('#')[0], 
                                        'ingredient_details': row[1],
                                        'structured_ingredient': row[0] })} 


CSV.read('database/recipes.csv',
  {:col_sep => '|'}).map { |row| recipes.save({ 
                                        'id': row[0],
                                        'all_ingredients': hashmap[row[0]].join('|'),
                                        'recipe_name': row[1], 
                                        'preparation': row[2] }) }

CSV.read('database/ingredients.csv',
  {:col_sep => '|'}).map { |row| ingredients.save({ 
                                        'id': row[1], 
                                        'url_key': row[0], 
                                        'ingredient_name': row[2] }) }


