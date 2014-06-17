# encoding: utf-8

require "bunny"

conn = Bunny.new("amqp://nchulytf:-ks2JvgwoLddQfEPW7i7Rwdpo_gij2yq@tiger.cloudamqp.com/nchulytf")
conn.start

ch   = conn.create_channel

q    = ch.queue("reposicion", :auto_delete => true)

ch.prefetch(1)
puts " [*] Worker de Reposiciones. Salir con CTRL+C"


consumer = q.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, body|
	puts " [x] Recibido"
	# imitate some work
	puts body
	
	msg = body[1..-2].strip.split(',')
	puts msg
	
	sku = msg[0].split(':')[1][1..-2].to_i
	puts sku
	
	sleep 5
	puts " [x] Procesado"
	ch.ack(delivery_info.delivery_tag)
end

puts "Consumer: #{consumer.consumer_tag} created"

sleep 1

# Cancel consumer
cancel_ok = consumer.cancel

puts "Consumer: #{cancel_ok.consumer_tag} cancelled"

ch.close