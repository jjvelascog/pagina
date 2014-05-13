require_relative 'almacen.rb'
require_relative 'vtiger.rb'
require_relative 'almacen.rb'

#puts Vtiger::get_address_from_rut('4362743-0')

almacen = Almacen.new()

despacho = "53571d16682f95b80b7685b6"

puts skus = almacen.get_skus(despacho)
puts skus[0]['_id']
puts id = almacen.first(skus[0]['_id'],despacho)

puts almacen.borrar(id,"Direccion","1000","PedidoId")
#puts almacen.get_stock(skus[0]['_id'])
#puts almacen.despachar(skus[0]['_id'], 2, "Av. Las conde", "1000", "13")
