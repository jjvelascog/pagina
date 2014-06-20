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
     		#img = Spree::Image.create(:attachment => open(texto[i]['imagen']), :viewable => p.master)
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
  
  def pedidos
    
  end
  
  def dashboard
    map = %Q{
      function() {
        if (this.producto_ocupados == null) return;
        for (i=0; i<this.producto_ocupados.length; i++ ){
          emit(this.rut, { ingreso: NumberInt(this.producto_ocupados[i].ingreso), costo: NumberInt(this.producto_ocupados[i].costo)});
        }
      }
    }
    
    reduce = %Q{
      function(key, values) {
        var result = { ingreso: NumberInt(0), costo: NumberInt(0)};
        values.forEach(function(value) {
          result.ingreso += value.ingreso;
          result.costo += values.costo;
        });
        return result;
      }
    }
    
    clientes = Pedido_cliente.map_reduce(map, reduce).out(inline: true)
    
    arreglo = []
    clientes.each do |result|
        arreglo << [result["_id"] , result["value"]["ingreso"],result["value"]["costo"]]
    end
    
    arreglo = arreglo.sort_by{|e| -e[1]}
    
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Pedidos por cliente")
      f.xAxis(:categories => [arreglo[0][0], arreglo[1][0], arreglo[2][0], arreglo[3][0], arreglo[4][0]])
      f.series(:name => "Ingresos", :data => [arreglo[0][1], arreglo[1][1], arreglo[2][1], arreglo[3][1], arreglo[4][1]])
      f.series(:name => "Costos", :data => [arreglo[0][2], arreglo[1][2], arreglo[2][2], arreglo[3][2], arreglo[4][2]])

    
      f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
      f.chart({:defaultSeriesType=>"column"})
    end
  end

end
