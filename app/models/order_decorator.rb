module Spree
	Order.class_eval do
		state_machine do
			after_transition :to => :complete, :do => :hacer_algo
		end

		def hacer_algo
			puts "number: "+self.number.to_s
			puts "===================================="
			puts "===================================="
			puts "===================================="
			orden = Spree::Order.find_by_number(self.number)
			n_orden = orden.id
			line_todo = Spree::LineItem.where(order_id: n_orden)
			direccion_id = orden.ship_address_id
			dir = Spree::Address.find(direccion_id)
			direccion = "#{dir.firstname} #{dir.lastname}, #{dir.address1}, #{dir.city}"
			puts 'direccion: ' + direccion
			for i in 0..line_todo.length-1
				line = line_todo[i]
				variant_id = line.variant_id
				sku = Spree::Variant.find(variant_id).sku
				puts 'precio: '+ line.price.to_s
				puts 'cantidad: ' + line.quantity.to_s
				puts 'sku: ' + sku
				puts "==="
			end
		end
	end
end