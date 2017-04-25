class Restauranttime < ActiveRecord::Base
	self.table_name = 'time'
  	self.primary_key = 'name', 'id', 'day', 'open', 'close' 
end
