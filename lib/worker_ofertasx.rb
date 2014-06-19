# encoding: utf-8
require 'metodo_twitter.rb'
require "bunny"

#conn = Bunny.new("amqp://nchulytf:-ks2JvgwoLddQfEPW7i7Rwdpo_gij2yq@tiger.cloudamqp.com/nchulytf")
#conn.start

#ch = conn.create_channel

#q = ch.queue("ofertas", :auto_delete => true)

#ch.prefetch(1)
puts " [*] Worker de Ofertas. Salir con CTRL+C"
puts " [---------------------------------]"

begin
	#consumer = q.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, body|
	for i in 1000..1001
		puts " [x] Oferta Recibida"
		body= "{\"sku\":\"#{3549664+i}\",\"precio\":5555,\"inicio\":1379800001000,\"fin\":1379844601000}"
		puts " [x] Body: #{body}"
		
		#procesar
		msg = body[1..-2].strip.split(',')
		#puts " [x] Mensaje: #{msg}"
		
		sku = msg[0].split(':')[1][1..-2].to_s
		puts " [o] Sku: #{sku}"
		
		precio = msg[1].split(':')[1].to_i
		puts " [o] Precio: #{precio}"
		
		inicio = msg[2].split(':')[1].to_i
		puts " [o] Inicio: #{inicio}"
		
		fin = msg[3].split(':')[1].to_i
		puts " [o] Fin: #{fin}"
		
		#logica de ofertas
		Metodo_twitter.processOferta(sku, precio, inicio, fin)
		sleep 1
		
		puts " [x] Oferta Procesada"
		#ch.ack(delivery_info.delivery_tag)
		
		puts " [---------------------------------]"
	end
rescue Interrupt => _
	#cancel_ok = consumer.cancel
	#puts "Consumer: #{cancel_ok.consumer_tag} cancelado"
	
	#conn.close
end