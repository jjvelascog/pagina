class Metodo_twitter
require "rubygems"
require 'sqlite3'

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

	def self.processOferta(sku_input, precio_input, inicio, fin)
		#item_input=Item.where(sku: '#{sku_input}')
		#Item.create!(:sku => "3548644", :precio => 369990, :precio_internet => 329990, :marca => "Apple",:modelo => "iPad Retina 9\" 32 GB Wi-Fi")
		#item_input=Item.new
		sku=sku_input
		marca="Apple"
		modelo="iPad Retina 9\" 32 GB Wi-Fi"
		precio=369990
		precio_internet=329990 #consultar en el spree
		#item_input.save

		fecha_inicio= Date.strptime((inicio/1000).to_s, '%s')
		fecha_fin= Date.strptime((fin/1000).to_s, '%s')



		mensaje="OFERTA DEL #{fecha_inicio} AL #{fecha_fin}! #{marca} #{modelo} - ANTES: $#{precio_internet} | AHORA: $#{precio_input}"

		postTweet(mensaje)
	end
end