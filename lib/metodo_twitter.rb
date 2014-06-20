class Metodo_twitter
require "rubygems"
require 'sqlite3'
require 'welcome.rb'

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
		item_input=Item.find(sku_input)

		sku=sku_input
		marca=item_input.marca
		modelo=item_input.modelo
		#precio=369990
		precio_internet=item_input.precio_internet
		if(!precio_internet)
			precio_internet=Producto.where(sku: sku_input).first.precio
		elsif(precio_internet<=0)
			precio_internet=Producto.where(sku: sku_input).first.precio

		end 


		fecha_inicio= Date.strptime((inicio/1000).to_s, '%s')
		fecha_fin= Date.strptime((fin/1000).to_s, '%s')
		hora_inicio=Time.at(inicio/1000)
		hora_fin=Time.at(fin/1000)

		Welcome.CrearPromocion(precio_input, sku_input, hora_inicio, hora_fin)

		mensaje="OFERTA DEL #{fecha_inicio} AL #{fecha_fin}! #{marca} #{modelo} - ANTES: $#{precio_internet} | AHORA: $#{precio_input}"

		postTweet(mensaje)
	end

	def self.publicarOfertas
		now = Time.now

		Spree::SalePrice.where(start_at: Time.now.to_date).each do |oferta|
	  	id=oferta.price_id
	  	sku=Spree::Variant.find(id)
	  	precio=oferta.value
	  	inicio=oferta.start_at
	  	fin=oferta.end_at

	  	processOferta(sku,precio,inicio,fin)
	end
end