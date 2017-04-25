class Restauranttheme < ActiveRecord::Base
	self.table_name = 'restaurant_theme'
  	self.primary_key = 'id'
  	belongs_to :restaurant_vital
end
