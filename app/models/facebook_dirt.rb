class FacebookDirt
   @@total_photos = 0 

	def initialize(auth)
		@token = auth
		@facebook = Koala::Facebook::API.new(@token)
		Obscenity::Base.whitelist   = ["aids", "baller", "balling", 
        "big baller", "bigballer", "cocaine", "condom", 
        "crap", "devil", "eggplant", "drugs", "flip",
        "hell", "genocide", "ho", "kill", "lsd", "marijuana",
        "murder", "pcp", "psilocybin", "redneck", "slope",
        "suicide", "transvestite", "transexual", "party"]
	end

	def obscene_photos
		set_obscenity_config_photo
		response = @facebook.get_object("me/photos")
		photos = []
		while response != [] && !response.nil?
			photos << get_photos_for_a_page(response)
			response = response.next_page
		end
		photos.flatten
	end

	def get_photos_for_a_page(response)
		photos = []
		response.each do |res|
			photos << res if obscene_photo?(res)
      @@total_photos += 1
		end
		photos
	end

  def self.total_photos
    @@total_photos
  end

	def obscene_photo?(res)
		if !res["comments"].nil?
			res["comments"]["data"].each do |comment|
				return true if profane_comment?(comment["message"])
			end
		end
		false
	end

	def profane_comment?(message)
		# message = message.split(" ")
		# message.each do |word|
		# 	return true if PROFANE_WORDS.include?(word)
		# end
		Obscenity.profane?(message)
		# false
	end

	def set_obscenity_config_photo
		Obscenity::Base.whitelist   = ["aids", "baller", "balling", 
        "big baller", "bigballer", "cocaine", "condom", 
        "crap", "devil", "eggplant", "drugs", "flip",
        "hell", "genocide", "ho", "kill", "lsd", "marijuana",
        "murder", "pcp", "psilocybin", "redneck", "slope",
        "suicide", "transvestite", "transexual", "fuck"]
	end

	def obscene_statuses
		#response = JSON.parse(IO.read("app/test_data/kana_data.json"))
		
		# Production
  	response = @facebook.get_object("me/statuses?limit=100")
  	statuses = []
  	while response != []
  		statuses << get_statuses_for_a_page(response)
  		response = response.next_page
  	end
		statuses.flatten
	end

	def get_statuses_for_a_page(response)
		statuses = []
		response.each do |res|
			if Obscenity.profane?(res["message"])
				statuses << res
			end
		end
		statuses
	end

	def get_name
		@facebook.get_object("me")["name"]
	end

end