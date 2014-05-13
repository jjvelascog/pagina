class Almacen
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
	  return self.stock(sku,@main)+self.stock(sku,@pulmon)
	end
  
  def despachar(sku, cantidad, direccion, precio, pedidoId)
    cantidadDespachada = 0
    
    cantidadMain = self.stock(sku,@main)
    cantidadPulmon = self.stock(sku,@pulmon)
    
    while cantidadDespachada < cantidad do
      if(cantidadPulmon != 0)
        id = self.first(sku,@pulmon)
        
        self.mover(id,@despacho)
        self.borrar(id,direccion, precio, pedidoId)

        cantidadPulmon -= 1
        cantidadDespachada += 1
      elsif(cantidadMain != 0)
        id = self.first(sku,@main)
        
        self.mover(id,@despacho)
        self.borrar(id,direccion, precio, pedidoId)
        
        #TODO Mover desde el pulmon
        cantidadMain -= 1
        cantidadDespachada += 1
      else
        break
      end  
    end
    return cantidadDespachada
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
  
end

