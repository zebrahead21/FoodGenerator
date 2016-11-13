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

# hashmap cu cheie reteta si valorea lista de ingrediente folosite, despartite printr-un '|'
# are buguri momentan din cauza inputului
# e citita in indexul de retete
# folosita pentru cautarea dupa mai multe ingrediente

CSV.read('database/relationships.csv',
  {:col_sep => '|'}).map { |row| hashmap[row[3].split('#')[0]] ||= []
                                 hashmap[row[3].split('#')[0]] << row[3].split('#')[1] 
                                 relationships.save({ 
                                        'id': Digest::SHA256.hexdigest(row[3]),
                                        'ingredient_id': row[3].split('#')[1], 
                                        'recipe_id': row[3].split('#')[0], 
                                        'quantity': row[0], 
                                        'unit_measure': row[1],
                                        'semi_preparation': row[4],
                                        'structured_ingredient': row[2] })} 
puts
puts
puts hashmap
puts
puts

CSV.read('database/recipes.csv',
  {:col_sep => '|'}).map { |row| recipes.save({ 
                                        'id': row[0],
                                        'all_ingredients': hashmap[row[0]].join('|'),
                                        'descr': row[1], 
                                        'preparation': row[2] }) }

CSV.read('database/ingredients.csv',
  {:col_sep => '|'}).map { |row| ingredients.save({ 
                                        'id': row[1], 
                                        'url_key': row[0], 
                                        'description': row[2] }) }


