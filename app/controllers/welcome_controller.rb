class WelcomeController < ApplicationController
  def index
  end
  
  	def cargarJson
  	filepath = "#{Rails.root}/productos.json"
    data =File.open(filepath).read
    categorias = Spree::Taxonomy.find_by_name("Categoria")
    r_categorias = categorias.root
    marcas = Spree::Taxonomy.find_by_name("Marca")
    r_marcas = marcas.root
 	  texto = JSON.parse(data)
   	for i in 0...texto.length
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
		filepath = "#{Rails.root}/productos.json"
    data =File.open(filepath).read
 	  texto = JSON.parse(data)
   	for i in 0...texto.length
      if not producto = Spree::Variant.find_by_sku(texto[i]['sku'])
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
  
  def pedidos
    
  end
  
  def showPedido
    @pedido = Pedido_cliente.find(params[:id])
  end
  
  def pedidosSpree
    
  end
  
  def showPedidoSpree
    @pedido = Pedido_spree.find(params[:id])
  end
  
    def pedidosBodega
    
  end
  
  def showPedidoBodega
    @pedido = Pedido_bodega.find(params[:id])
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
    
    map2 = %Q{
      function() {
        if (this.producto_ocupados == null) return;
        for (i=0; i<this.producto_ocupados.length; i++ ){
          emit("a", { ingreso: NumberInt(this.producto_ocupados[i].ingreso), cantidad: NumberInt(this.producto_ocupados[i].cantidad_despachada)});
        }
      }
    }
    
    reduce2 = %Q{
      function(key, values) {
        var result = { ingreso: NumberInt(0), cantidad: NumberInt(0)};
        values.forEach(function(value) {
          result.ingreso += value.ingreso;
          result.cantidad += value.cantidad;
        });
        return result;
      }
    }
    
    sftp = Pedido_cliente.map_reduce(map2, reduce2).out(inline: true)
    spree = Pedido_spree.map_reduce(map2, reduce2).out(inline: true)
    bodega = Pedido_bodega.map_reduce(map2, reduce2).out(inline: true)
    
    puts "====================="
    puts sftp.first["value"]["cantidad"]
    puts sftp.first["value"]["ingreso"]
    puts sftp.first
    puts "====================="
    
    @chart2 = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [50, 200, 60, 170]} )
      series = {
               :type=> 'pie',
               :name=> 'Cantidad Despachada',
               :data=> [
                  ['Pedidos spree',  spree.first["value"]["cantidad"]],
                  ['Pedidos bodegas',  bodega.first["value"]["cantidad"]],
                  {
                     :name=> 'Pedidos ftp',    
                     :y=> sftp.first["value"]["cantidad"],
                     :sliced=> true,
                     :selected=> true
                  }
               ]
      }
      f.series(series)
      f.options[:title][:text] = "THA PIE"
      f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'}) 
      f.plot_options(:pie=>{
        :allowPointSelect=>true, 
        :cursor=>"pointer" , 
        :dataLabels=>{
          :enabled=>true,
          :color=>"black",
          :style=>{
            :font=>"13px Trebuchet MS, Verdana, sans-serif"
          }
        }
      })
end
  end

end
