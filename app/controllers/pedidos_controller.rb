class PedidosController < ApplicationController
  
  def venta
    require 'date'

    #TODO Pablo Revisar validez datos
   
  	pedido = session[:tmp_pedido]
  	@show_pedido = pedido
  	session[:tmp_pedido] = nil
    
    address = Vtiger.get_address_from_rut(pedido['Pedidos'][0]['rut'][0])
    pedidoId = "no hay" #TODO Nacho obtener Id del pedido
    @show_adress = address
    @show_rut = pedido['Pedidos'][0]['rut'][0]
    @show_productos = []
    
    pedido['Pedidos'][0]['Pedido'].each do |aux|
      #Tania Revisar si existen los productos (ver sku)
      sku=aux['sku'][0].strip
      break if Producto.where(sku: sku).count==0 #Si el sku no existe, se salta ese pedido
      
      #Tania Validar que precio esté vigente
      fecha_vig=Producto.where(sku: sku).order(:fechavig).last[:fechavig]
      break if fecha_vig < DateTime.now.strftime('%m/%d/%Y')
  
      precio = Producto.where(sku: sku).first[:precio] #tania
      #TODO Guardar en el DW si se pide un producto que no está?
    
      almacen = Almacen.new()  
      stock = almacen.get_stock(aux['sku'][0].strip)
      
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
	    cantidad_pedida = aux['cantidad'][0]['content'].to_f
	  
      if(reserva_tuya == 0)
        if(stock_disponible > cantidad_pedida)
          cantidad_despachada = almacen.despachar(sku, cantidad_pedida, address, precio, pedidoId)
        else
          #Quiebra
        end
      else
        if(stock < cantidad_pedida)
          #Quiebra
          #TODO Pablo Pedir a otras bodegas 
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
      producto = [sku,cantidad_pedida,stock,precio, total_reservas,reserva_tuya,cantidad_despachada]
      @show_productos << producto
    end
    #Guardar en data Warehouse #TODO Juan Jose
  end
end
