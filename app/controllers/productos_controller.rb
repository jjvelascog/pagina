require "rubygems"

class ProductosController < ApplicationController
  def actualizar
  	#Producto.actualizar
	

	Producto.leeraccess
	redirect_to(all_productos_path)
  end

  def index
    #Producto.actualizar
  end


end
