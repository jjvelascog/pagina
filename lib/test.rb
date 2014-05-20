require_relative 'almacen.rb'
require_relative 'vtiger.rb'
require_relative 'almacen.rb'

#puts Vtiger::get_address_from_rut('4362743-0')

almacen = Almacen.new()


despacho = "53571d16682f95b80b7685b5"

puts skus = almacen.get_skus(despacho)

almacen.despejarRecepcion
#puts almacen.pedir(2419210,2)
#puts sku = skus[0]['_id']
#puts id = almacen.first(skus[0]['_id'],despacho)

#puts almacen.borrar(id,"Direccion","1000","PedidoId")
#puts almacen.get_stock(skus[0]['_id'])
#puts almacen.mover(id,"53571d1c682f95b80b76e5e9")
