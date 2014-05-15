
class PedidosController < ApplicationController
  
  def venta
  require 'Date'

    #TODO Pablo Revisar validez datos
   
    
	pedido = session[:tmp_pedido]
	@showpedido = pedido
	session[:tmp_pedido] = nil
    address = Vtiger.get_address_from_rut(pedido['Pedidos'][0]['rut'][0]) #TODO Arturo
    
    pedido['Pedidos'][0]['Pedido'].each do |aux|
      
      #Tania Revisar si existen los productos
      sku=aux['sku'][0].strip
      break if Producto.where(sku: sku).count==0 #Si el sku no existe, se salta ese pedido
      #TODO Tania: Validar que precio esté vigente
      #USAR EL QUE TIENE LA ULTIMA FECHA DE ACTUALIZACIÓN
      fecha_vig=Producto.where(sku: sku).order(:fechavig).last[:fechavig]
      #break if fecha_vig < Date.today

      precio = Producto.where(sku: sku).first[:precio] #tania
      #OJO: precio y sku son int
      # GUARDAR en el DW si se pide un producto que no está?


      almacen = Almacen.new()
      

      stock = almacen.get_stock(aux['sku'][0].strip)
	  puts sku
    puts precio
    puts stock
      reserva = Reserva.where(sku: aux['sku'][0].strip)
      if(!reserva.empty?)
        total_reservas = reserva.sum(:cantidad)
        reserva_propia = reserva.where(cliente: pedido['Pedidos'][0]['rut'][0])
        if (!reserva_propia.empty?)
          reserva_tuya = @reserva_propia.first.cantidad
        else
          reserva_tuya = 0
        end
      else
        total_reservas = 0
        reserva_tuya = 0
      end
      
      stock_disponible = stock-total_reservas+reserva_tuya     
      
	  puts aux['cantidad'][0]['content'].to_f
	  
      if(reserva_tuya == 0)
        if(stock_disponible > aux['cantidad'][0]['content'].to_f)
          #despachar #TODO ignacio 
          #Guardar en data Warehouse #TODO Juan Jose
        else
          #Quiebra
          #Guardar en data Warehouse
        end
      else
        if(stock < aux['cantidad'][0]['content'].to_f )
          #Quiebra
          #Pedir a otras bodegas #TODO Pablo 
          #Guardar en data Warehouse 
        else
          if(reserva_tuya > aux['cantidad'][0]['content'].to_f)
            #Restar en reserva
            #Despachar
            #Guardar en DW
          elsif(reserva_tuya == aux['cantidad'][0]['content'].to_f)  
            #Borrar reserva
            #Despachar
            #Guardar en DW
          else
            if(stock_disponible >= aux['cantidad'][0]['content'].to_f)
              #Borrar reserva
              #Despachar
              #Guardar en DW
            else
              #Quiebra
              #Guardar en data Warehouse 
            end        
          end      
        end
      end
    end
	
	@showadd = address
  end
end
