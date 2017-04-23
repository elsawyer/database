class RestaurantVital < ActiveRecord::Base
  self.table_name = 'restaurant_vital'
  self.primary_key = 'id'
  has_one :restauranttheme, foreign_key: "id"
end
