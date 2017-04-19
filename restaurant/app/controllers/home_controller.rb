class HomeController < ApplicationController
	def index
		#sleep until HTML 5 gets permission for location tracking
		#TODO: if no permission, maybe link to an error page - rn probably sleeps forever
		while (!cookies[:lat_lng]) 
			sleep(1)
		end

		#hardcoded user id - replace with login info later on
		@user = 'test'

		#turn cookies into array
		@lat_lng = cookies[:lat_lng].split("|")
		lat = (@lat_lng[0]).to_f
		long = (@lat_lng[1]).to_f

		#hardcoded prefs for now
		prefs = []
		prefsStr = ["%italian%", "%sushi%"]


		addr = Geocoder.address([lat, long]).split(",")
		city = addr[1].strip()
		state  = addr[2].split(" ")[0].strip()
		cityState = "%" + city + " " + state + "%"

		timezone = Timezone.lookup(lat,long)
		curTime = Time.now.in_time_zone(timezone.name).strftime("%H:%M")
		weekDay = Time.now.in_time_zone(timezone.name).strftime("%A")
		print curTime + "\n\n"
		print weekDay + "\n\n"

		#userid is a primary key, so we get a single tuple here
		userData = User.where("userid = ?", @user)[0]
		minPrice = userData["minprice"]
		maxPrice = userData["maxprice"]
		drinks = userData["drinks"]
		homelat = userData["homelat"]
		homelong = userData["homelong"]

		#calculate user's home address
		homeAddr = Geocoder.address([homelat, homelong]).split(",")
		homeCity = homeAddr[1].strip()
		homeState  = homeAddr[2].split(" ")[0].strip()
		homeCityState = "%" + homeCity + " " + homeState + "%"
		print homeCityState + "\n\n"


		#query the userlikes db to get user selected preferences
		userPrefs = Userlike.select("foodlike").where("userid = ?", @user)

		#iterate through prefs, add to list of normal strings, add to list of "regex" strings
		userPrefs.each do |post|
			post = post["foodlike"]
			print post
			pref = "%" + post + "%"
			prefsStr.push(pref)
			prefs.push(post)
		end

		#query suggestions database and add to the pref list
		recs = GenericType.select("related").where("typename = ANY ( array[?] )", prefs)
		recs.each do |rec|
			rec = rec["related"]
			add_rec = "%" + rec + "%"
			prefsStr.push(add_rec)
		end


  		#order by random helps keep us from offering same suggestion every time
  		#distance function is loaded into db - uses the Haversine formula to calculate linear distance between longs and lats
    	@suggestions = RestaurantVital.where("restaurant_type ilike any ( array[?] ) AND location like ?", prefsStr, cityState).where(" ( distance ( latitude::REAL, longitude::REAL, ?::REAL, ?::REAL ) / 1609.344 ) <= 3", lat, long).limit(3).order("RANDOM()")
    	print @suggestions[1]["phone"] + "\n\n"

    	#query using homelat/homelong - preload data for toggle
    	@home_suggestions = RestaurantVital.where("restaurant_type ilike any ( array[?] ) AND location like ?", prefsStr, homeCityState).where(" ( distance ( latitude::REAL, longitude::REAL, ?::REAL, ?::REAL ) / 1609.344 ) <= 25", homelat, homelong).limit(3).order("RANDOM()")
    	print @home_suggestions[1]["name"] + "\n\n"
  	end
end
