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
          result.costo += value.costo;
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
    x = []
    y1 = []
    y2 = []
    arreglo.take(10).each do |a|
      x << Vtiger.get_name_from_rut(a[0])
      y1 << a[1]
      y2 << a[2]
    end
    
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Clientes Principales")
      f.xAxis(:categories => x)
      f.series(:name => "Ingresos", :data => y1)
      f.series(:name => "Costos", :data => y2)

    
      f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
      f.chart({:type=>"bar", :defaultSeriesType=>"bar", :height=>600})
    end
    
    map2 = %Q{
      function() {
        if (this.producto_ocupados == null) return;
        for (i=0; i<this.producto_ocupados.length; i++ ){
          emit("a", { ingreso: NumberInt(this.producto_ocupados[i].ingreso), cantidad: NumberInt(this.producto_ocupados[i].cantidad_despachada), cantidadPedida: NumberInt(this.producto_ocupados[i].cantidad_pedida)});
        }
      }
    }
    
    reduce2 = %Q{
      function(key, values) {
        var result = { ingreso: NumberInt(0), cantidad: NumberInt(0), cantidadPedida: NumberInt(0)};
        values.forEach(function(value) {
          result.ingreso += value.ingreso;
          result.cantidad += value.cantidad;
          result.cantidadPedida += value.cantidadPedida;
        });
        return result;
      }
    }
    
    sftp = Pedido_cliente.map_reduce(map2, reduce2).out(inline: true)
    spree = Pedido_spree.map_reduce(map2, reduce2).out(inline: true)
    bodega = Pedido_bodega.map_reduce(map2, reduce2).out(inline: true)
    
    @chart2 = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [30, 5, 5, 5], :height=>300} )
      series = {
               :type=> 'pie',
               :name=> 'Cantidad Despachada',
               :data=> [
                  ['Pedidos spree', bodega.first["value"]["cantidad"]],
                  ['Pedidos bodegas', spree.first["value"]["cantidad"]],
                  {
                     :name=> 'Pedidos ftp',    
                     :y=> sftp.first["value"]["cantidad"],
                     :sliced=> true,
                     :selected=> true
                  }
               ]
      }
      f.series(series)
      f.options[:title][:text] = "Cantidad despachada"
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
      
    @chart3 = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [30, 5, 5, 5], :height=>300} )
      series = {
               :type=> 'pie',
               :name=> 'Ingresos',
               :data=> [
                  ['Pedidos spree', bodega.first["value"]["ingreso"]],
                  ['Pedidos bodegas', spree.first["value"]["ingreso"]],
                  {
                     :name=> 'Pedidos ftp',    
                     :y=> sftp.first["value"]["ingreso"],
                     :sliced=> true,
                     :selected=> true
                  }
               ]
      }
      f.series(series)
      f.options[:title][:text] = "Ingresos"
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
    @pedidaSftp = sftp.first["value"]["cantidadPedida"]
    @despachadaSftp =  sftp.first["value"]["cantidad"]
    if (@pedidaSftp == 0)
      @porcentajeSftp  = 0
    else
      @porcentajeSftp  = @despachadaSftp / @pedidaSftp
    end
    @pedidaSpree = spree.first["value"]["cantidadPedida"]
    @despachadaSpree =  spree.first["value"]["cantidad"]
    if (@pedidaSpree == 0)
      @porcentajeSpree  = 0
    else
      @porcentajeSpree  = @despachadaSpree / @pedidaSpree
    end
    @pedidaBodega = bodega.first["value"]["cantidadPedida"]
    @despachadaBodega =  bodega.first["value"]["cantidad"]
    if (@pedidaBodega == 0)
      @porcentajeBodega  = 0
    else
      @porcentajeBodega  = @despachadaBodega / @pedidaBodega
    end
    
    map3 = %Q{
      function() {
        if (this.producto_ocupados == null) return;
        for (i=0; i<this.producto_ocupados.length; i++ ){
          emit(this.id_bodega, { cantidad: NumberInt(this.producto_ocupados[i].cantidad_despachada), cantidadPedida: NumberInt(this.producto_ocupados[i].cantidad_pedida)});
        }
      }
    }
    
    reduce3 = %Q{
      function(key, values) {
        var result = { cantidad: NumberInt(0), cantidadPedida: NumberInt(0)};
        values.forEach(function(value) {
          result.cantidad += value.cantidad;
          result.cantidadPedida += value.cantidadPedida;
        });
        return result;
      }
    }
    
    clientes = Pedido_bodega.map_reduce(map3, reduce3).out(inline: true)
    
    arreglo = []
    clientes.each do |result|
        arreglo << [result["_id"] , result["value"]["cantidad"],result["value"]["cantidadPedida"]]
    end
    
    arreglo = arreglo.sort_by! {|e| e[0]}
    x = []
    y1 = []
    y2 = []
    arreglo.each do |a|
      x << a[0]
      y1 << a[1]
      y2 << a[2]
    end
    
    @chart4 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Pedidos de otras bodegas")
      f.xAxis(:categories => x)
      f.series(:name => "Cantidad Pedida", :data => y2)
      f.series(:name => "Cantidad Despachada", :data => y1)

    
      f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
      f.chart({:type=>"column", :defaultSeriesType=>"column", :height=>600})
    end
    
    map4 = %Q{
      function() {
        emit(this.id_bodega, { cantidad: NumberInt(this.cantidad_recibida), cantidadPedida: NumberInt(this.cantidad_pedida)});
      }
    }
    
    reduce4 = %Q{
      function(key, values) {
        var result = { cantidad: NumberInt(0), cantidadPedida: NumberInt(0)};
        values.forEach(function(value) {
          result.cantidad += value.cantidad;
          result.cantidadPedida += value.cantidadPedida;
        });
        return result;
      }
    }
    
    clientes = Solicitud_bodega.map_reduce(map4, reduce4).out(inline: true)
    
    arreglo = []
    clientes.each do |result|
        arreglo << [result["_id"] , result["value"]["cantidad"],result["value"]["cantidadPedida"]]
    end
    
    arreglo = arreglo.sort_by! {|e| e[0]}
    x = []
    y1 = []
    y2 = []
    arreglo.each do |a|
      x << a[0]
      y1 << a[1]
      y2 << a[2]
    end
    
    @chart5 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Pedidos de otras bodegas")
      f.xAxis(:categories => x)
      f.series(:name => "Cantidad Pedida", :data => y2)
      f.series(:name => "Cantidad Recibida", :data => y1)

    
      f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
      f.chart({:type=>"column", :defaultSeriesType=>"column", :height=>600})
    end
  end

end
