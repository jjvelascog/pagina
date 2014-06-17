# encoding: utf-8

require "bunny"

conn = Bunny.new("amqp://nchulytf:-ks2JvgwoLddQfEPW7i7Rwdpo_gij2yq@tiger.cloudamqp.com/nchulytf")
conn.start

ch   = conn.create_channel
q    = ch.queue("reposicion", :auto_delete => true)

# declare default direct exchange which is bound to all queues
e = conn.exchange("")

# publish a message to the exchange which then gets routed to the queue
e.publish("Hello, everybody!", :key => q.name)

puts " [x] Sent 'test'"

conn.close