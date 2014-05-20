class WelcomeController < ApplicationController
  def index
  end
  
  	def cargarJson
		data = File.read('productos.json')
 	  	texto = JSON.parse(data)
   		for i in 0...texto.length
   			@item = Items.new({ "sku" => texto[i]['sku'], "marca" => texto[i]['marca'], "modelo" => texto[i]['modelo'], "precio_internet" => texto[i]['precio']['internet'], "precio" => texto[i]['precio']['normal'], "descripcion" => texto[i]['descripcion'], "imagen" => texto[i]['imagen']})
 			@item.save
   		end
   		redirect_to items_path
	end
end
