require_relative 'welcome.rb'
require_relative 'almacen.rb'

almacen = Almacen.new()


despacho = "53571d16682f95b80b7685b7"
pulmon = "53571d1c682f95b80b76e5e9"

puts skus = almacen.get_skus(pulmon)

puts almacen.pedir(3461611,2)

#2419210