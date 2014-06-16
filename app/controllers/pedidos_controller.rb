class PedidosController < ApplicationController
  
  def venta
  	todo = Metodo_sftp.index()
  	@show_pedido = todo[0]
    @show_archivo = todo[1]
    @show_adress = todo[2]
    @show_rut = todo[3]
    @show_productos = todo[4]
  end
  
end
