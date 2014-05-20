class Metodo_venta
  
  def self.venta(pedido, pedidoId)
    require 'date'

    #TODO Pablo Revisar validez datos
    almacen = Almacen.new() 
    
    @show_pedido = pedido
  
    @show_archivo = pedidoId
    
    address = Vtiger.get_address_from_rut(pedido['Pedidos'][0]['rut'][0])
    
    @show_adress = address
    @show_rut = pedido['Pedidos'][0]['rut'][0]
    @show_productos = []
    
    pedido['Pedidos'][0]['Pedido'].each do |aux|
      
      stock = almacen.get_stock(aux['sku'][0].strip)
      cantidad_pedida = aux['cantidad'][0]['content'].to_f
      
      #Tania Revisar si existen los productos (ver sku)
      sku=aux['sku'][0].strip
      if Producto.where(sku: sku).count==0 #Si el sku no existe, se salta ese pedido
        producto = [sku,cantidad_pedida,stock,"el producto no exite", "","","",false]
        @show_productos << producto
        next
      end
      
      #Tania Validar que precio esté vigente
      fecha_vig=Producto.where(sku: sku).order(:fechavig).last[:fechavig]
      if fecha_vig < DateTime.now.strftime('%m/%d/%Y')
        producto = [sku,cantidad_pedida,stock,"precio no vigente", "","","",false]
        @show_productos << producto
        next
      end
  
      precio = Producto.where(sku: sku).first[:precio] #tania
      #TODO Guardar en el DW si se pide un producto que no está?
     
      stock = almacen.get_stock(aux['sku'][0].strip)
      solicitud_otros = false
      
      reserva = Reserva.where(sku: aux['sku'][0].strip)
      if(!reserva.empty?)
        total_reservas = reserva.sum(:cantidad)
        reserva_propia = reserva.where(cliente: pedido['Pedidos'][0]['rut'][0])
        if (!reserva_propia.empty?)
          reserva_tuya = reserva_propia.first.cantidad
        else
          reserva_tuya = 0
        end
      else
        total_reservas = 0
        reserva_tuya = 0
      end
      
      stock_disponible = stock-total_reservas+reserva_tuya     
      cantidad_despachada = 0
    
      if(reserva_tuya == 0)
        if(stock_disponible > cantidad_pedida)
          cantidad_despachada = almacen.despachar(sku, cantidad_pedida, address, precio, pedidoId)
        else
          #Quiebra
        end
      else
        if(stock < cantidad_pedida)
          #Quiebra
          Thread.new{pedir_a_otra_bodega(sku,cantidad_pedida)}
          solicitud_otros = true
        else
          if(reserva_tuya > cantidad_pedida)
            reserva_propia.first.cantidad -= cantidad_pedida
            reserva_propia.first.save
            cantidad_despachada = almacen.despachar(sku, cantidad_pedida, address, precio, pedidoId)
          elsif(reserva_tuya == cantidad_pedida)  
            reserva_propia.destroy
            cantidad_despachada = almacen.despachar(sku, cantidad_pedida, address, precio, pedidoId)
          else
            if(stock_disponible >= cantidad_pedida)
              reserva_propia.destroy
              cantidad_despachada = almacen.despachar(sku, cantidad_pedida, address, precio, pedidoId)
            else
              #Quiebra
            end        
          end      
        end
      end
      producto = [sku,cantidad_pedida,stock,precio, total_reservas,reserva_tuya,cantidad_despachada,solicitud_otros]
      @show_productos << producto
    end
    #Guardar en data Warehouse #TODO Juan Jose
    return [@show_pedido,@show_archivo,@show_adress,@show_rut,@show_productos]
  end
  
  def pedir_a_otra_bodega(sku, cantidad)
    almacen2 = Almacen.new()
    almacen2.pedir(sku, cantidad)
  end
end