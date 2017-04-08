class HomeController < ApplicationController
  def index
  	query = "SELECT * FROM restaurant_vital LIMIT 10"
  	@suggestions = RestaurantVital.connection.execute(query)
  end
end
