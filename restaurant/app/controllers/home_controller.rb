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

		addr = Geocoder.address([lat, long]).split(",")
		city = addr[1].strip()
		state  = addr[2].split(" ")[0].strip()
		cityState = "%" + city + " " + state + "%"

		timezone = Timezone.lookup(lat,long)
		curTime = Time.now.in_time_zone(timezone.name).strftime("%H:%M")
		weekDay = Time.now.in_time_zone(timezone.name).strftime("%A")
		print curTime + "\n\n"
		print weekDay + "\n\n"

  		#order by random helps keep us from offering same suggestion every time
  		#distance function is loaded into db - uses the Haversine formula to calculate linear distance between longs and lats
    	@suggestions = RestaurantVital.where("restaurant_type ilike any ( array[?] ) AND location like ?", prefs, cityState).where(" ( distance ( latitude::REAL, longitude::REAL, ?::REAL, ?::REAL ) / 1609.344 ) <= 3", lat, long).limit(3).order("RANDOM()")
    	print @suggestions[1]["phone"] + "\n\n"
  	end
end
