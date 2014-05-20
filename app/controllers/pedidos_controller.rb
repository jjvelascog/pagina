class PedidosController < ApplicationController
  
  def venta
    require 'date'
  	todo = session[:tmp_todo]
  	@show_pedido = todo[0]
    @show_archivo = todo[1]
    @show_adress = todo[2]
    @show_rut = todo[3]
    @show_productos = todo[4]

  	session[:tmp_todo] = nil
  end
  
  def pedir_a_otra_bodega(sku, cantidad)
    almacen2 = Almacen.new()
    almacen2.pedir(sku, cantidad)
  end
end
