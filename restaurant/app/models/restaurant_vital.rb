class RestaurantVital < ActiveRecord::Base
  self.table_name = 'restaurant_vital'
  self.primary_key = 'id'
  class << self
  	def self.findNearby()
  		restaurants = self.connection_select_value("SELECT * FROM restaurant_vital LIMIT 10")
  		return restaurants 
  	end
  end
end
