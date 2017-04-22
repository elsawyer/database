class GenericType < ActiveRecord::Base
	self.table_name = 'generic_type'
  	self.primary_key = 'typename', 'related' 
end
