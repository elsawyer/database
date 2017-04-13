class RestaurantVital < ActiveRecord::Base
  self.table_name = 'restaurant_vital'
  self.primary_key = 'id'
  def self.nearby()
  	query = "SELECT name FROM restaurant_vital LIMIT 10"
  	return self.connection.execute(query)
  end
end
