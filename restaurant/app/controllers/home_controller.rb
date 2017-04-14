class HomeController < ApplicationController
	def index
		#sleep until HTML 5 gets permission for location tracking
		#TODO: if no permission, maybe link to an error page - rn probably sleeps forever
		while (!cookies[:lat_lng]) 
			sleep(1)
		end

		#turn cookies into array
		@lat_lng = cookies[:lat_lng].split("|")
		lat = (@lat_lng[0]).to_f
		long = (@lat_lng[1]).to_f

		#hardcoded prefs for now
		prefs = ["%italian%", "%sushi%"]


		print "lat and long:\n\n\n\n\n"
		print(@lat_lng)
		addr = Geocoder.address([lat, long]).split(",")
		city = addr[1].strip()
		state  = addr[2].split(" ")[0].strip()
		cityState = "%" + city + " " + state + "%"
		print cityState
  		#order by random helps keep us from offering same suggestion every time
  		#restaurants = self.connection_select_value("SELECT * FROM restaurant_vital ORDER BY RANDOM() LIMIT 4 ")
  		#query = "SELECT * FROM restaurant_vital LIMIT 10"
  		#@suggestions = RestaurantVital.connection.execute(query)
    	#@suggestions = RestaurantVital.limit(4)
    	@suggestions = RestaurantVital.where("restaurant_type ilike any ( array[?] ) AND location like ?", prefs, cityState).limit(4).order("RANDOM()")
  	end
end
