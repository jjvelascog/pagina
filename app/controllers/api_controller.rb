class ApiController < ApplicationController
protect_from_forgery with: :null_session
  def pedirProducto

   username = params[:usuario]
	 contrasena = params[:password]
	 almacen_id = params[:almacen_id]
	 sku = params[:SKU]
	 cantidad = params[:cantidad].to_i
  	  
    if BodegasVecinas.find_by(username: params[:usuario], password: params[:password]).nil?
    error = "Nombre de usuario o password invalida"
    render json: {error: error} and return
    end
  	alm = Almacen.new
    respuesta=alm.despachar_a_otros(sku,cantidad,almacen_id)
    if respuesta>0
      render json: {sku: sku, cantidad: respuesta} and return
    elsif respuesta == 0
      render json: {error: "No hay stock disponible"} and return
    end

    
  end
end
