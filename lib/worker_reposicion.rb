# encoding: utf-8
require 'almacen.rb'
require 'welcome.rb'
require "bunny"

conn = Bunny.new("amqp://nchulytf:-ks2JvgwoLddQfEPW7i7Rwdpo_gij2yq@tiger.cloudamqp.com/nchulytf")
conn.start

ch = conn.create_channel

q = ch.queue("reposicion", :auto_delete => true)

ch.prefetch(1)
puts " [*] Worker de Reposiciones. Salir con CTRL+C"
puts " [---------------------------------]"

begin
	consumer = q.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, body|
		puts " [x] Reposicion Recibida"
		
		puts " [x] Body: #{body}"
		
		#procesar
		msg = body[1..-2].strip.split(',')
		#puts " [x] Mensaje: #{msg}"
		
		sku = msg[0].split(':')[1][1..-2].to_s
		puts " [o] Sku: #{sku}"
		
		fecha = msg[1].split(':')[1].to_i
		puts " [o] Fecha: #{fecha}"
		
		almacenId = msg[2].split(':')[1][1..-2].to_s
		puts " [o] almaceId: #{almacenId}"
		
		#logica de reposicion
		almacen = Almacen.new()
		
		almacen.despejarRecepcion
		#TODO actualizar tabla spree
		Welcome.AgregarStock(sku, 1)
		sleep 1
		
		puts " [x] Reposicion Procesada"
		ch.ack(delivery_info.delivery_tag)
		
		puts " [---------------------------------]"
	end
rescue Interrupt => _
	cancel_ok = consumer.cancel
	puts "Consumer: #{cancel_ok.consumer_tag} cancelado"
	
	conn.close
end