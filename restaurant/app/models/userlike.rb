class Userlike < ActiveRecord::Base
	self.table_name = 'user_like'
  	self.primary_key = 'userid'
end
