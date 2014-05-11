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
	
	def initialize(type)
		signature = 'GET'
    aut = @@aut_header+Base64.encode64("#{OpenSSL::HMAC.digest('sha1',@@key, signature)}")
    consulta = HTTParty.get(@@base_uri+"/almacenes",:headers => { "Authorization" => aut})
		case type
      when "pulmon"
  		  consulta.each do |i|
          if (i[@@pulmon])
            @id = i[@@id]
            @space = i[@@espacio]
            @used = i[@@usado]
          end
        end
  		when "recepcion"
  		  consulta.each do |i|
          if (i[@@recepcion])
            @id = i[@@id]
            @space = i[@@espacio]
            @used = i[@@usado]
          end
        end
      when "despacho"
        consulta.each do |i|
          if (i[@@despacho])
            @id = i[@@id]
            @space = i[@@espacio]
            @used = i[@@usado]
          end
        end
  		when "main"
  		  @space = 0
        consulta.each do |i|
          if (!i[@@pulmon])
            if ( @space == 0 or @space < i[@@espacio])
              @id = i[@@id]
              @space = i[@@espacio]
              @used = i[@@usado]
            end
          end
        end
      else
        puts "error"
    end
	end

	def get_stock(sku)
	  #TODO
	  signature = 'GET'+@id+sku
    aut = @@aut_header+Base64.encode64("#{OpenSSL::HMAC.digest('sha1',@@key, signature)}")
    consulta = HTTParty.get(@@base_uri+"/stock",:headers => { "Authorization" => aut},:query => {"almacenId" => @id, "sku" => sku, "limit" => "200"})
    return consulta.size
	end

  def get_skus()
    #TODO
    signature = 'GET'+@id
    aut = @@aut_header+Base64.encode64("#{OpenSSL::HMAC.digest('sha1',@@key, signature)}")
    consulta = HTTParty.get(@@base_uri+"/skusWithStock",:headers => { "Authorization" => aut},:query => {"almacenId" => @id})
    return consulta
  end
  
end

