
class PedidosController < ApplicationController
  
  def venta
    
    #TODO Pablo Revisar validez datos
    #TODO Tania Revisar si existen los productos
    
	pedido = session[:tmp_pedido]
	session[:tmp_pedido] = nil
    address = Vtiger.get_address_from_rut(pedido['Pedidos'][0]['rut'][0]) #TODO Arturo
    
    pedido['Pedidos'][0]['Pedido'].each do |aux|
      precio = 1000 #Producto.where("sku=?",aux['sku'][0]).first.precio #TODO tania
      almacen = Almacen.new()
      

      stock = almacen.get_stock(aux['sku'][0])
      reserva = Reserva.where(sku: aux['sku'][0])
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
      
      if(reserva_tuya == 0)
        if(stock_disponible > aux['cantidad'][0]['content'])
          #despachar #TODO ignacio 
          #Guardar en data Warehouse #TODO Juan Jose
        else
          #Quiebra
          #Guardar en data Warehouse
        end
      else
        if(stock < aux['cantidad'][0]['content'] )
          #Quiebra
          #Pedir a otras bodegas #TODO Pablo 
          #Guardar en data Warehouse 
        else
          if(reserva_tuya > aux['cantidad'][0]['content'])
            #Restar en reserva
            #Despachar
            #Guardar en DW
          elsif(reserva_tuya == aux['cantidad'][0]['content'])  
            #Borrar reserva
            #Despachar
            #Guardar en DW
          else
            if(stock_disponible >= aux['cantidad'][0]['content'])
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
  end
end
