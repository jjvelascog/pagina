class Metodo_twitter
	def self.postTweet(tweet)

		require 'oauth'
		require 'twitter'
		
		client = Twitter::REST::Client.new do |config|
			config.consumer_key        = "Sz6Wofp2opTiLdQwcTW6fmJQy"
			config.consumer_secret     = "3gc52icWi9upP6LVF8lUjjHYWSORN9VNn6a7O4YQYGWOEJ7eBd"  
			config.access_token        = "2548231651-hjq9v4Mqw0qrh9WOMVFSiobLSJoMyKbgAY32FwP"  
			config.access_token_secret = "3V8P8wC4jwmR5bE1TP6KxWJcTqE765thUpVnPGJgbvyw6"
		end
		client.update(tweet)
	end
end