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

    #guardar pedido en dw
    pedidoDW = Pedido_cliente.new(rut: @show_rut, pedidoId: pedidoId, fecha: Date.today, direccion: address)
    
    pedido['Pedidos'][0]['Pedido'].each do |aux|
      
      stock = almacen.get_stock(aux['sku'][0].strip)
      cantidad_pedida = aux['cantidad'][0]['content'].to_f

      #Tania Revisar si existen los productos (ver sku)
      sku=aux['sku'][0].strip
      if Producto.where(sku: sku).count==0 #Si el sku no existe, se salta ese pedido
        producto = [sku,cantidad_pedida,stock,"el producto no exite", "","","",""]
        @show_productos << producto
        break
      end
      
      #Tania Validar que precio esté vigente
      fecha_vig=Producto.where(sku: sku).order(:fechavig).last[:fechavig]
      if fecha_vig < DateTime.now.strftime('%m/%d/%Y')
        producto = [sku,cantidad_pedida,stock,"precio no vigente", "","","",""]
        @show_productos << producto
        break
      end
  
      precio = Producto.where(sku: sku).first[:precio] #tania
      #TODO Guardar en el DW si se pide un producto que no está?
     
      stock = almacen.get_stock(aux['sku'][0].strip)
      solicitud_otros = 0
      
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
      costo = 0
    
      if(reserva_tuya == 0)
        if(stock_disponible > cantidad_pedida)
          temp = almacen.despachar(sku, cantidad_pedida, address, precio, pedidoId)
          cantidad_despachada = temp[0]
          costo = temp[1]
        else
          solicitud_otros = almacen.pedir(sku,cantidad_pedida-stock_disponible)
          if(stock_disponible+solicitud_otros > 0)
            temp = almacen.despachar(sku, stock_disponible+solicitud_otros, address, precio, pedidoId)
            cantidad_despachada = temp[0]
            costo = temp[1]
          end
        end
      else
        if(stock < cantidad_pedida)
          #Quiebra (no tiene suficiente stock)
          #Thread.new{pedir_a_otra_bodega(sku,cantidad_pedida)}
          if(reserva_tuya >= cantidad_pedida)
            solicitud_otros = almacen.pedir(sku,cantidad_pedida-stock)
            temp = almacen.despachar(sku, cantidad_pedida, address, precio, pedidoId)
            cantidad_despachada = temp[0]
            costo = temp[1]
            reserva_propia.first.cantidad -= cantidad_despachada
            reserva_propia.first.save
            if (reserva_propia.first.cantidad <= 0)
              reserva_propia.destroy_all
            end
          else
            solicitud_otros = almacen.pedir(sku,cantidad_pedida-stock_disponible)
            temp = almacen.despachar(sku, cantidad_pedida, address, precio, pedidoId)
            cantidad_despachada = temp[0]
            costo = temp[1]    
            reserva_propia.first.cantidad -= cantidad_despachada
            reserva_propia.first.save
            if (reserva_propia.first.cantidad <= 0)
              reserva_propia.destroy_all
            end
          end
        else
          if(reserva_tuya > cantidad_pedida)
            temp = almacen.despachar(sku, cantidad_pedida, address, precio, pedidoId)
            cantidad_despachada = temp[0]
            costo = temp[1]
            reserva_propia.first.cantidad -= cantidad_despachada
            #Reserva_ocupada.create(sku: sku, cantidad: cantidad_despachada, pedidoId: pedidoId)
            reserva_propia.first.save
          elsif(reserva_tuya == cantidad_pedida)  
            reserva_propia.destroy_all
            temp = almacen.despachar(sku, cantidad_pedida, address, precio, pedidoId)
            cantidad_despachada = temp[0]
            costo = temp[1]
            #Reserva_ocupada.create(sku: sku, cantidad: cantidad_despachada, pedidoId: pedidoId)
          else
            if(stock_disponible >= cantidad_pedida)
              reserva_propia.destroy_all
              #Reserva_ocupada.create(sku: sku, cantidad: reserva_tuya, pedidoId: pedidoId)
              temp = almacen.despachar(sku, cantidad_pedida, address, precio, pedidoId)
              cantidad_despachada = temp[0]
              costo = temp[1]
            else
              #Quiebra (hay stock pero su reserva es menor al pedido)
              solicitud_otros = almacen.pedir(sku,cantidad_pedida-stock_disponible)
              temp = almacen.despachar(sku, cantidad_pedida, address, precio, pedidoId)
              cantidad_despachada = temp[0]
              costo = temp[1]
              reserva_propia.first.cantidad -= cantidad_despachada
              #Reserva_ocupada.create(sku: sku, cantidad: cantidad_despachada, pedidoId: pedidoId)
              reserva_propia.first.save
              if (reserva_propia.first.cantidad <= 0)
                reserva_propia.destroy_all
              end
            end        
          end      
        end
      end
      producto = [sku,cantidad_pedida,stock,precio, total_reservas,reserva_tuya,cantidad_despachada,solicitud_otros]
      @show_productos << producto
      #Guardar en DW
      pedidoDW.producto_ocupados.new(sku: sku, cantidad_pedida: cantidad_pedida, cantidad_despachada: cantidad_despachada, ingreso: cantidad_despachada*precio.to_i, costo: costo)
      if (cantidad_pedida > cantidad_despachada)
        pedidoDW.quebrados.new(sku: sku, cantidad: cantidad_pedida-cantidad_despachada, pedidoId: pedidoId)
      end
      if (reserva_tuya != 0 and cantidad_despachad != 0 )
        pedidoDW.reserva_ocupadas.new(sku: sku, cantidad: [cantidad_despachada,reserva_tuya].min, pedidoId: pedidoId)
      end
    end
    pedidoDW.save
    return [@show_pedido,@show_archivo,@show_adress,@show_rut,@show_productos]
  end
  
  def pedir_a_otra_bodega(sku, cantidad)
    almacen2 = Almacen.new()
    almacen2.pedir(sku, cantidad)
  end
end