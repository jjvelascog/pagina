
class PedidosController < ApplicationController
  
  def venta(pedido)
    
    #TODO Pablo Revisar validez datos
    #TODO Tania Revisar si existen los productos
    
    address = Vtiger.get_address_from_rut(pedido['rut']) #TODO Arturo
    
    pedido['producto'].each do |aux|
      precio = Producto.where("sku=?",aux['sku']).first.precio #TODO tania
      almacen = Almacen.new()
      
      stock = almacen.get_stock(aux['sku'])
      reserva_tuya = Reserva.where(sku: aux['sku']).where(cliente: pedido['rut']).first.cantidad #TODO ignacio
      total_reservas = Reserva.where(sku: aux['sku']).sum(:cantidad) #TODO ignacio
      
      stock_disponible = stock-total_reservas+reserva_tuya     
      
      if(reserva_tuya == 0)
        if(stock_disponible > aux['cantidad'])
          #despachar #TODO ignacio 
          #Guardar en data Warehouse #TODO Juan Jose
        else
          #Quiebra
          #Guardar en data Warehouse
        end
      else
        if(stock < aux['cantidad'] )
          #Quiebra
          #Pedir a otras bodegas #TODO Pablo 
          #Guardar en data Warehouse 
        else
          if(reserva_tuya > aux['cantidad'])
            #Restar en reserva
            #Despachar
            #Guardar en DW
          elsif(reserva_tuya == aux['cantidad'])  
            #Borrar reserva
            #Despachar
            #Guardar en DW
          else
            if(stock_disponible >= aux['cantidad'])
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
