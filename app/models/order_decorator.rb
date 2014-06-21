require "almacen.rb"

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
      nombre = "#{dir.firstname} #{dir.lastname}"
      
			puts 'direccion: ' + direccion
			alm = Almacen.new()
			pedidoDW = Pedido_spree.new(nombre: nombre, fecha: Date.today, direccion: direccion)

			for i in 0..line_todo.length-1
				line = line_todo[i]
				variant_id = line.variant_id
				sku = Spree::Variant.find(variant_id).sku
				precio = line.price
				cantidad = line.quantity
				#puts "variant_id"+variant_id
				#puts "sku"+sku
				#puts cantidad
				temp = alm.despachar(sku, cantidad, direccion, precio.to_s,"-1")
				cantidad_despachada = temp[0]
        costo = temp[1]
				pedidoDW.producto_ocupados.new(sku: sku, cantidad_pedida: cantidad, cantidad_despachada: cantidad_despachada, ingreso: cantidad_despachada*precio, costo: costo)
			end
			pedidoDW.save
		end
	end
end