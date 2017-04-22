class RegisterController < ApplicationController
	def index
		render :register
	end
	def register

		#get stuff out of the form
		@name = params[:form_first_name]
		@zip = params[:form_ZIP]
		@italian = params[:italian]
		@med = params[:mediterranean]
		@mex = params[:mexican]
		@chinese = params[:chinese]
		@breakfast = params[:breakfast]
		@american = params[:american]
		@fastfood = params[:fast_food]
		@sushi = params[:sushi]
		@indian = params[:indian]
		@price = params[:money_slide]
		@email = params[:form_email]
		@user= @name

		#create new user in the database
		#User.create({ :userid => @email, :maxprice => @price, :zip => @zip.to_i })
		User.create({userid: @email, maxprice: @price.to_i, zip: @zip.to_i})

		#add to user likes as necessary - convert type of food to yelp keyword
		if @italian
			Userlike.create(:userid=>@email, :foodlike=>"italian", :islike=>TRUE)
		end
		if @med
			Userlike.create(:userid=>@email, :foodlike=>"mediterranean", :islike=>TRUE)
		end
		if @mex
			Userlike.create(:userid=>@email, :foodlike=>"mexican", :islike=>TRUE)
		end
		if @chinese
			Userlike.create(:userid=>@email, :foodlike=>"chinese", :islike=>TRUE)
		end
		if @breakfast
			Userlike.create(:userid=>@email, :foodlike=>"breakfast", :islike=>TRUE)
		end
		if @american
			Userlike.create(:userid=>@email, :foodlike=>"tradamerican", :islike=>TRUE)
		end
		if @fastfood
			Userlike.create(:userid=>@email, :foodlike=>"hotdogs", :islike=>TRUE)
		end
		if @sushi
			Userlike.create(:userid=>@email, :foodlike=>"sushi", :islike=>TRUE)
		end
		if @indian
			Userlike.create(:userid=>@email, :foodlike=>"indpak", :islike=>TRUE)
		end

		redirect_to 'home/index' and return
	end
end
