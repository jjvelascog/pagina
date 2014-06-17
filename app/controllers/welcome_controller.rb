class WelcomeController < ApplicationController
  def index
  end
  
  	def cargarJson
		data = File.read('productos.json')
    categorias = Spree::Taxonomy.find_by_name("Categoria")
    r_categorias = categorias.root
    marcas = Spree::Taxonomy.find_by_name("Marca")
    r_marcas = marcas.root
 	  texto = JSON.parse(data)
   	for i in 0...100
   		@item = Items.new({ "sku" => texto[i]['sku'], "marca" => texto[i]['marca'], "modelo" => texto[i]['modelo'], "precio_internet" => texto[i]['precio']['internet'], "precio" => texto[i]['precio']['normal'], "descripcion" => texto[i]['descripcion'], "imagen" => texto[i]['imagen']})
 		  begin
        @item.save
      rescue
      end
      if not taxon1 = Spree::Taxon.find_by_name(texto[i]['marca'])
        Spree::Taxon.create(:name => texto[i]['marca'], :parent_id => r_marcas.id)
      end
      for j in 0..texto[i]['categorias'].length-1
        if not taxon2 = Spree::Taxon.find_by_name(texto[i]['categorias'][j])
          Spree::Taxon.create(:name => texto[i]['categorias'][j], :parent_id => r_categorias.id)
        end
      end
   	end
   		redirect_to items_path
    end

	def cargarSpree
		data = File.read('productos.json')
 	  texto = JSON.parse(data)
   	for i in 0...100
      if not produco = Spree::Product.find_by_name(texto[i]['modelo'])
   		  p = Spree::Product.create :name => texto[i]['modelo'], :price => texto[i]['precio']['internet'], :description => texto[i]['descripcion'], :sku => texto[i]['sku'], :shipping_category_id => 1, :available_on => Time.now
     		img = Spree::Image.create(:attachment => open(texto[i]['imagen']), :viewable => p.master)
        p.taxons << Spree::Taxon.find_by_name(texto[i]['marca'])
        for j in 0..texto[i]['categorias'].length-1
          taxon = Spree::Taxon.find_by_name(texto[i]['categorias'][j])
          begin
          p.taxons << taxon
          rescue
          end
        end
      end
   	end
   	redirect_to items_path
	end

  def prueba
    data = File.read('productos.json')
    texto = JSON.parse(data)
    for i in 0..10
      CambiarStock(texto[i]['modelo'], 14)
    end
    redirect_to root_path
  end

  def CambiarStock(p, c)
    producto = Spree::Product.find_by_name(p)
    producto.master.stock_items.first.update_column(:count_on_hand, c)
  end

end
