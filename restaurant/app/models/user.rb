class User < ActiveRecord::Base
  self.table_name = 'users'
  self.primary_key = 'userid'
end
