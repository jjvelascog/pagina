class PedidosController < ApplicationController
  
  def venta
    resultado = Metodo_sftp.index()
  	@show_pedido = resultado[0]
	  @show_archivo = resultado[1]
    @show_adress = resultado[2]
    @show_rut = resultado[3]
    @show_productos = resultado[4]
  end
  
end
