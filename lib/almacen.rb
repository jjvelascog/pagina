class Almacen
  require 'welcome.rb'
	require "rubygems"
	require "httparty"
	require 'base64'
	require 'openssl'

	@@base_uri = "http://bodega-integracion-2014.herokuapp.com"
	@@key = 'MDRrbrJ7'
	@@aut_header = "UC grupo4:"	

	@@id = "_id"
	@@pulmon = "pulmon" 
	@@despacho = "despacho" 
	@@recepcion = "recepcion" 
	@@espacio = "totalSpace" 
	@@usado = "usedSpace" 
	@@version = "__v"

	def getRecepcion()
		return @recepcion
	end
	def initialize()
		signature = 'GET'
    aut = @@aut_header+Base64.encode64("#{OpenSSL::HMAC.digest('sha1',@@key, signature)}")
    consulta = HTTParty.get(@@base_uri+"/almacenes",:headers => { "Authorization" => aut})
	  space = 0
    consulta.each do |i|
      if(i[@@pulmon])
        @pulmon = i[@@id]
      elsif(i[@@despacho])
        @despacho = i[@@id]
      elsif(i[@@recepcion])
        @recepcion = i[@@id]
      else
        if ( space == 0 or space < i[@@espacio])
          @main= i[@@id]
          space = i[@@espacio]
        end
      end
    end
	end

	def get_stock(sku)
	  return self.stock(sku,@main)+self.stock(sku,@pulmon)+self.stock(sku,@recepcion)
	end
  
  def despachar(sku, cantidad, direccion, precio, pedidoId)
    #Pedido.create(sku: sku, cantidad: cantidad, precio: precio, pedidoId: pedidoId)
    cantidadDespachada = 0
    costo = 0
    
    cantidadMain = self.stock(sku,@main)
    cantidadPulmon = self.stock(sku,@pulmon)
    cantidadRecepcion = self.stock(sku,@recepcion)
    
    while cantidadDespachada < cantidad do
      if(cantidadPulmon != 0)
        id = self.first(sku,@pulmon)
        
        res1 = self.mover(id,@despacho)
        res2 = self.borrar(id,direccion, precio, pedidoId)
        if(res2.code != 200)
          puts "pulmon #{res2}"
          self.mover(id,@main)
          break
        end
        costo += res2["costo"].to_i
        cantidadPulmon -= 1
        cantidadDespachada += 1
      elsif(cantidadRecepcion != 0)
        id = self.first(sku,@recepcion)
        
        res1 = self.mover(id,@despacho)
        res2 = self.borrar(id,direccion, precio, pedidoId)
        if(res2.code != 200)
          puts "recepcion #{res2}"
          self.mover(id,@recepcion)
          break
        end
        costo += res2["costo"].to_i
        cantidadRecepcion -= 1
        cantidadDespachada += 1
      elsif(cantidadMain != 0)
        id = self.first(sku,@main)
        
        res1 = self.mover(id,@despacho)
        res2 = self.borrar(id,direccion, precio, pedidoId)
        if(res2.code != 200)
          puts "main #{res2.code}"
          self.mover(id,@main)
          break
        end
        costo += res2["costo"].to_i
        #self.sacarDePulmon()
        cantidadMain -= 1
        cantidadDespachada += 1
      else
        break
      end
    end
    #Actualizar stock del spree:
    puts "Despachado producto: #{sku}"
    Welcome.AgregarStock(sku, -cantidadDespachada)
    costo += cantidadDespachada*Producto.get_costo(sku)
    return [cantidadDespachada,costo]
  end
  
  def mover(id, destino)
    signature3 = 'POST'+id+destino
    aut3 = @@aut_header+Base64.encode64("#{OpenSSL::HMAC.digest('sha1',@@key, signature3)}")
    return HTTParty.post(@@base_uri+"/moveStock",:headers => { "Authorization" => aut3},:body => {"almacenId" => destino, "productoId" => id}) 
  end
  
  def borrar(id, direccion, precio, pedidoId)
    signature = 'DELETE'+id+direccion+precio+pedidoId
    aut = @@aut_header+Base64.encode64("#{OpenSSL::HMAC.digest('sha1',@@key, signature)}")
    return HTTParty.delete(@@base_uri+"/stock",:headers => { "Authorization" => aut},:body=> {"productoId" => id, "direccion" => direccion, "precio" => precio, "pedidoId" => pedidoId})
  end
  
  def stock(sku, almacen)
    signature = 'GET'+almacen+sku
    aut = @@aut_header+Base64.encode64("#{OpenSSL::HMAC.digest('sha1',@@key, signature)}")
    consulta = HTTParty.get(@@base_uri+"/stock",:headers => { "Authorization" => aut},:query => {"almacenId" => almacen, "sku" => sku, "limit" => "200"})
    return consulta.size
  end
  
  def get_skus(almacen)
    signature = 'GET'+almacen
    aut = @@aut_header+Base64.encode64("#{OpenSSL::HMAC.digest('sha1',@@key, signature)}")
    consulta = HTTParty.get(@@base_uri+"/skusWithStock",:headers => { "Authorization" => aut},:query => {"almacenId" => almacen})
    return consulta
  end
  
  def first(sku, almacen)
    signature = 'GET'+almacen+sku
    aut = @@aut_header+Base64.encode64("#{OpenSSL::HMAC.digest('sha1',@@key, signature)}")
    consulta = HTTParty.get(@@base_uri+"/stock",:headers => { "Authorization" => aut},:query => {"almacenId" => almacen, "sku" => sku, "limit" => "200"})
    return consulta[0]['_id']
  end
  
  def sacarDePulmon()
    puts skus = self.get_skus(@pulmon)
    if(skus.size != 0)
      sku = skus[0]['_id']
      id = self.first(skus[0]['_id'],@pulmon)
      respuesta = self.mover(id,@main)
      if(respuesta.code = 200)
        return 1
      end
    end
    return 0
  end
  
  def pedir(sku, cantidad)
    cantidad_recibida = 0
    #Probada
    if (cantidad_recibida < cantidad)
      tempPedida = cantidad - cantidad_recibida
      begin
        response = HTTParty.post("http://integra5.ing.puc.cl/api/v1/pedirProducto",:body => { "usuario" => "grupo4", "password" => "373f3f314f442d67ec9512e24b82d550e72a2ec3", "sku" => sku, "cantidad" => cantidad - cantidad_recibida, "almacenId" => @recepcion}) 
        if (response.code == 200 and response.key?("cantidad"))
          tempRecibida = response["cantidad"]
          cantidad_recibida += tempRecibida
          Solicitud_bodega.create(id_bodega: 5, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: tempRecibida)
        else
          Solicitud_bodega.create(id_bodega: 5, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
        end
      rescue
        Solicitud_bodega.create(id_bodega: 5, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
      end
    end
    if (cantidad_recibida < cantidad)
      tempPedida = cantidad - cantidad_recibida
      begin
        response = HTTParty.post("http://integra6.ing.puc.cl/apiGrupo/pedido",:body => { "usuario" => "grupo4", "password" => "373f3f314f442d67ec9512e24b82d550e72a2ec3", "SKU" => sku, "cantidad" => cantidad - cantidad_recibida, "almacen_id" => @recepcion}) 
        if (response.code == 200 and response.key?("cantidad"))
          tempRecibida = response["cantidad"]
          cantidad_recibida += tempRecibida
          Solicitud_bodega.create(id_bodega: 6, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: tempRecibida)
        else
          Solicitud_bodega.create(id_bodega: 6, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
        end
      rescue
        Solicitud_bodega.create(id_bodega: 6, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
      end
    end
    if (cantidad_recibida < cantidad)
      tempPedida = cantidad - cantidad_recibida
      begin
        response = HTTParty.get("http://integra7.ing.puc.cl/api/api_request",:query => { "usuario" => "grupo4", "password" => "86bdc4bf03b372559e52cfa5e3bd2a8e1528e232", "sku" => sku, "cantidad" => cantidad - cantidad_recibida, "almacen_id" => @recepcion}) 
        if (response.code == 200 and response.key?("cantidad"))
          tempRecibida = response["cantidad"]
          cantidad_recibida += tempRecibida
          Solicitud_bodega.create(id_bodega: 7, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: tempRecibida)
        else
          Solicitud_bodega.create(id_bodega: 7, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
        end
      rescue
        Solicitud_bodega.create(id_bodega: 7, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
      end
    end
    #Probada
    if (cantidad_recibida < cantidad)
      tempPedida = cantidad - cantidad_recibida
      begin
        response = HTTParty.post("http://integra8.ing.puc.cl/api/pedirProducto",:body => { "usuario" => "grupo4", "password" => "grupo4integra", "SKU" => sku, "cantidad" => cantidad - cantidad_recibida, "almacen_id" => @recepcion}) 
        if (response.code == 200 and response.key?("cantidad"))
          tempRecibida = response["cantidad"]
          cantidad_recibida += tempRecibida
          Solicitud_bodega.create(id_bodega: 8, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: tempRecibida)
        else
          Solicitud_bodega.create(id_bodega: 8, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
        end
     rescue
       Solicitud_bodega.create(id_bodega: 8, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
     end
    end
    
    if (cantidad_recibida < cantidad)
      tempPedida = cantidad - cantidad_recibida
      begin
        response = HTTParty.post("http://integra9.ing.puc.cl/api/pedirProducto/grupo4/grupo4integra/#{sku}",:body => {"cantidad" => cantidad - cantidad_recibida, "almacenId" => @recepcion}) 
        if (response.code == 200 and response.key?("cantidad"))
          tempRecibida = response["cantidad"]
          cantidad_recibida += tempRecibida
          Solicitud_bodega.create(id_bodega: 9, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: tempRecibida)
        else
          Solicitud_bodega.create(id_bodega: 9, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
        end
      rescue
        Solicitud_bodega.create(id_bodega: 9, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
      end
    end
    if (cantidad_recibida < cantidad)
      tempPedida = cantidad - cantidad_recibida
      begin
        response = HTTParty.post("http://integra1.ing.puc.cl/ecommerce/api/v1/pedirProducto",:body => { "usuario" => "grupo4", "password" => "373f3f314f442d67ec9512e24b82d550e72a2ec3", "sku" => sku, "cant" => cantidad - cantidad_recibida, "almacenId" => @recepcion}) 
        if (response.code == 200 and response.key?("cantidad"))
          tempRecibida = response["cantidad"]
          cantidad_recibida += tempRecibida
          Solicitud_bodega.create(id_bodega: 1, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: tempRecibida)
        else
          Solicitud_bodega.create(id_bodega: 1, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
        end
      rescue
        Solicitud_bodega.create(id_bodega: 1, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
      end
    end
    #Probada
    if (cantidad_recibida < cantidad)
      tempPedida = cantidad - cantidad_recibida
      begin
        response = HTTParty.post("http://integra2.ing.puc.cl/api/pedirProducto",:body => { "usuario" => "grupo4", "password" => "373f3f314f442d67ec9512e24b82d550e72a2ec3", "SKU" => sku, "cantidad" => cantidad - cantidad_recibida, "almacen_id" => @recepcion})
        if (response.code == 200 and response.key?("cantidad"))
          tempRecibida = response["cantidad"]
          cantidad_recibida += tempRecibida
          Solicitud_bodega.create(id_bodega: 2, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: tempRecibida)
        else
          Solicitud_bodega.create(id_bodega: 2, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
        end
      rescue
        Solicitud_bodega.create(id_bodega: 2, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
      end
    end
    
    if (cantidad_recibida < cantidad)
      tempPedida = cantidad - cantidad_recibida
      begin
        response = HTTParty.post("http://integra3.ing.puc.cl/api/pedirProducto",:body => { "usuario" => "grupo4", "password" => "373f3f314f442d67ec9512e24b82d550e72a2ec3", "SKU" => sku, "cantidad" => cantidad - cantidad_recibida, "almacen_id" => @recepcion})
        if (response.code == 200 and response.key?("cantidad"))
          tempRecibida = response["cantidad"]
          cantidad_recibida += tempRecibida
          Solicitud_bodega.create(id_bodega: 3, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: tempRecibida)
        else
          Solicitud_bodega.create(id_bodega: 3, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
        end
      rescue
        Solicitud_bodega.create(id_bodega: 3, fecha: Date.today, sku: sku, cantidad_pedida: tempPedida, cantidad_recibida: 0)
      end
    end
    self.despejarRecepcion
    Welcome.AgregarStock(sku, cantidad_recibida)
    return cantidad_recibida
  end
  
  def mover_bodega(id, destino)
    signature = 'POST'+id+destino
    aut = @@aut_header+Base64.encode64("#{OpenSSL::HMAC.digest('sha1',@@key, signature)}")
    return HTTParty.post(@@base_uri+"/moveStockBodega",:headers => { "Authorization" => aut},:body => {"almacenId" => destino, "productoId" => id}) 
  end
  
  def despachar_a_otros(sku, cantidad, destino)
    cantidadDespachada = 0
    
    cantidadMain = self.stock(sku,@main)
    cantidadPulmon = self.stock(sku,@pulmon)
    
    while cantidadDespachada < cantidad do
      if(cantidadPulmon != 0)
        id = self.first(sku,@pulmon)
        
        res1 = self.mover(id,@despacho)
        res2 = self.mover_bodega(id,destino)
        if(res2.code != 200)
          self.mover(id,@pulmon)
          break
        end
        cantidadPulmon -= 1
        cantidadDespachada += 1
      elsif(cantidadMain != 0)
        id = self.first(sku,@main)
        
        res1 = self.mover(id,@despacho)
        res2 = self.mover_bodega(id,destino)
        if(res2.code != 200)
          self.mover(id,@main)
          break
        end
        #self.sacarDePulmon()
        cantidadMain -= 1
        cantidadDespachada += 1
      else
        break
      end  
    end
    #Actualizar stock Spree
    Welcome.AgregarStock(sku, -cantidadDespachada)

    return cantidadDespachada
  end
  
  def despejarRecepcion()
    skus = self.get_skus(@recepcion)
    cant_skus = skus.size - 1
    if (skus.size != 0)
      for i in 0..cant_skus
        sku = skus[i]['_id']
        cant  = skus[i]['total']
        for i in 1..cant   
          id = self.first(sku,@recepcion)
          #TODO verificar que main no este lleno
          respuesta = self.mover(id,@main)
          if(respuesta.code != 200)
            break
          end
        end
      end
    end
  end
  
end

