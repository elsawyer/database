class HomeController < ApplicationController

	def index
		print("MADE IT TO HOME")
		render :home
		#TODO: if no permission, maybe link to an error page - rn probably sleeps forever

		#print("got to controller")
		#while (!cookies[:lat_lng]) 
		# 	sleep(1)
		#end
		#print("got past sleep")

		#turn cookies into array
		#@lat_lng = cookies[:lat_lng].split("|")
		#lat = (@lat_lng[0]).to_f
		#long = (@lat_lng[1]).to_f

		lat = request.location.latitude
		long = request.location.longitude 

		#hardcode if on localhost
		if request.ip == '::1'
			lat = 37.272260
			long = -76.707002
		end

		prefs = []
		prefsStr = []
		recd= []

		timezone = Timezone.lookup(lat,long)
		curTime = Time.now.in_time_zone(timezone.name).strftime("%H:%M")
		weekDay = Time.now.in_time_zone(timezone.name).strftime("%A")
		weekDay = "%"+weekDay
		print curTime + "\n\n"
		print weekDay + "\n\n"

		#userid is a primary key, so we get a single tuple here
		userData = User.where("userid = ?", @user)[0]
		maxPrice = userData["maxprice"]
		drinks = userData["drinks"]
		homelat = userData["homelat"]
		homelong = userData["homelong"]
		distance = 0

		#query the userlikes db to get user selected preferences
		userPrefs = Userlike.select("foodlike").where("userid = ? AND isLike=TRUE", @user)

		#iterate through prefs, add to list of normal strings, add to list of "regex" strings
		userPrefs.each do |post|
			post = post["foodlike"]
			print post
			pref = "%" + post + "%"
			prefsStr.push(pref)
			prefs.push(post)
		end

		userDislikes = Userlike.select("foodlike").where("userid = ? AND isLike=FALSE", @user)

		dislikes=  []

		userDislikes.each do |dislike|
			dislikes.push(dislike["foodlike"])
		end

		#query suggestions database and add to the pref list: should not already be in pref list or in dislikes list
		recs = GenericType.select("related").where("typename = ANY ( array[?] )", prefs)
		recs.each do |rec|
			rec = rec["related"]
			if (prefs.include? rec) == false and (dislikes.include? rec) == false
				add_rec = "%" + rec + "%"
			end
			prefsStr.push(add_rec)
			recd.push(rec)
		end

		formatStr = "HH24:MI"

		times = Restauranttime.where("day = weekday AND to_timestamp(?) < close AND to_timestamp(?) > open", weekDay, curTime)

  		#order by random helps keep us from offering same suggestion every time
  		#distance function is loaded into db - uses the Haversine formula to calculate linear distance between longs and lats
    	@suggestions = RestaurantVital.where("restaurant_vital.restaurant_type ilike any ( array[?] ) AND ( distance ( latitude::REAL, longitude::REAL, ?::REAL, ?::REAL ) / 1609.344 ) <= 50", prefsStr, lat, long).joins("JOIN restaurant_theme ON restaurant_vital.id = restaurant_theme.id JOIN restaurant_times ON restaurant_times.id = restaurant_vital.id").where("char_length(price) <= ? AND rating::REAL >= 3.0", maxPrice).where("day like ? AND to_timestamp(?, ?)::time without time zone BETWEEN open AND close", weekDay, curTime, formatStr).limit(3).order("RANDOM()")

    	#try to handle "dead zones" where user's preferences are too specific for the area
    	if @suggestions.length < 2
    		#night-owl mode: check the time and see if its too late for anything to be open

    		#if user is willing to travel first, then increase distance by 10 miles
    		if distance == 1
    			@suggestions = RestaurantVital.where("restaurant_vital.restaurant_type ilike any ( array[?] ) AND ( distance ( latitude::REAL, longitude::REAL, ?::REAL, ?::REAL ) / 1609.344 ) <= 15", prefsStr, lat, long).joins("JOIN restaurant_theme ON restaurant_vital.id = restaurant_theme.id JOIN restaurant_times ON restaurant_times.id = restaurant_vital.id").where("char_length(price) <= ? AND rating::REAL >= 3.0", maxPrice).where("day = ? AND to_timestamp(?, ?)::time without time zone BETWEEN open AND close", weekDay, curTime, formatStr).limit(3).order("RANDOM()")
    		end
    		#if user is willing to increase price first, drop price constraint
    		if distance == 0
    			@suggestions = RestaurantVital.where("restaurant_vital.restaurant_type ilike any ( array[?] ) AND ( distance ( latitude::REAL, longitude::REAL, ?::REAL, ?::REAL ) / 1609.344 ) <= 50", prefsStr, lat, long).joins("JOIN restaurant_theme ON restaurant_vital.id = restaurant_theme.id JOIN restaurant_times ON restaurant_times.id = restaurant_vital.id").where("rating::REAL >= 3.0").where("day = ? AND to_timestamp(?, ?)::time without time zone BETWEEN open AND close", weekDay, curTime, formatStr).limit(3).order("RANDOM()")
    		end
    	end

    	@suggestions.each do |suggestion|
    		types = suggestion["restaurant_type"]
    		#if type is recommended and not pref'd, then add necessary elements
    		if (prefs.any? {|word| types.include? word}) == false and (recd.any? {|word| types.include? word}) == true
    			print "FOUND A REC!\n\n"
    		end
    	end

    	#query using homelat/homelong - preload data for toggle
    	#@home_suggestions = RestaurantVital.where("restaurant_type ilike any ( array[?] ) AND location like ?", prefsStr, homeCityState).where(" ( distance ( latitude::REAL, longitude::REAL, ?::REAL, ?::REAL ) / 1609.344 ) <= 25", homelat, homelong).limit(3).order("RANDOM()")
    	#print @home_suggestions[1]["name"] + "\n\n"

    	#go through recs and tag the ones that are suggested for the user - not resulting directly from their prefs
  	end
end
