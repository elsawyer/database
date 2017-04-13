class HomeController < ApplicationController
  def index
  	prefs = ["%italian%", "%sushi%"]
  	#order by random helps keep us from offering same suggestion every time
  	#restaurants = self.connection_select_value("SELECT * FROM restaurant_vital ORDER BY RANDOM() LIMIT 4 ")
  	#query = "SELECT * FROM restaurant_vital LIMIT 10"
  	#@suggestions = RestaurantVital.connection.execute(query)
    #@suggestions = RestaurantVital.limit(4)
    @suggestions = RestaurantVital.where("restaurant_type ilike any ( array[?] )", prefs).limit(4).order("RANDOM()")
  end
end
