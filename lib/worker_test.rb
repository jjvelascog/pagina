# encoding: utf-8

require "bunny"

conn = Bunny.new("amqp://nchulytf:-ks2JvgwoLddQfEPW7i7Rwdpo_gij2yq@tiger.cloudamqp.com/nchulytf")
conn.start

ch   = conn.create_channel

q    = ch.queue("reposicion", :auto_delete => true)

ch.prefetch(1)
puts " [*] Worker de Reposiciones. Salir con CTRL+C"

begin
  q.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, body|
    puts " [x] Recibido: '#{body}'"
    # imitate some work
	msg = body
	puts msg
    puts " [x] Procesado"
    ch.ack(delivery_info.delivery_tag)
  end
rescue Interrupt => _
  conn.close
end