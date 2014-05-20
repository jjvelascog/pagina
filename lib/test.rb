require_relative 'almacen.rb'
require_relative 'vtiger.rb'
require_relative 'almacen.rb'

#puts Vtiger::get_address_from_rut('4362743-0')

almacen = Almacen.new()


despacho = "53571d16682f95b80b7685b7"

puts skus = almacen.get_skus(despacho)

#almacen.despejarRecepcion
#puts almacen.pedir(2419210,2)
puts sku = skus[0]['_id']
puts id = almacen.first(skus[0]['_id'],despacho)

res = almacen.despachar(sku, 3, "Hola", "1000", "22")
puts res[0]
puts res[1]

#puts almacen.get_stock(skus[0]['_id'])
#puts almacen.mover(id,"53571d1c682f95b80b76e5e9")
