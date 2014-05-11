require_relative 'almacen.rb'
require_relative 'vtiger.rb'
require_relative 'almacen.rb'

#puts Vtiger::get_address_from_rut('4362743-0')

almacen = Almacen.new("main")
skus = almacen.get_skus
puts skus[0]['_id']
puts almacen.get_stock(skus[0]['_id'])
