class Metodo_sftp
  def self.index
  require 'xmlsimple'
  require 'net/sftp'
  
  @mensajeFinal = ""
  
  @xmlArray = Array.new
  @fileArray = Array.new
  @numArray = Array.new
  
  @tempEntryName = ""
  @tempEntryNum = ""
  @tempXml = ""
  @tempPedido = ""
  
  @lastNumero = 0
  
  #obtener numero ultimo pedido
  @last_pedido = LastPedido.find_or_create_by(id: '1') do |lp|
    lp.num = 0
  end
  
  @lastNumero = @last_pedido.num
  
  Net::SFTP.start('integra.ing.puc.cl', 'grupo4', :password => '498mdo') do |sftp|
    
    #obtener
    sftp.dir.glob("/home/grupo4/Pedidos/", "*.xml") do |entry|
      @tempEntryNum = entry.name[7..-5]
      @numArray.push @tempEntryNum
    end
    
    #sort
    @numArray = @numArray.map(&:to_i).sort
    
    @numArray.each do |num|
      #comparar con numero ultimo pedido
      if (num > @lastNumero) #nuevo pedido a leer
        #agregar pedidoid a session (pasar a sgte metodo)
        @pedidoId = num.to_s
        @fileArray.push num.to_s
		
        #abrir archivo
        file = sftp.file.open("/home/grupo4/Pedidos/pedido_#{num.to_s}.xml")
        
		#armar string con pedido
		@tempXml = file.gets
		@placeholderXml = file.gets
		@tempXml = "#{@tempXml}#{@placeholderXml}"
		@placeholderXml = file.gets
		@tempXml = "#{@tempXml}#{@placeholderXml}"
		
		#transformar xml
		
		if @tempXml.length > 0
			@tempPedido = XmlSimple.xml_in(@tempXml)
			
			#agregar pedido a session (pasar a sgte metodo)
			@xmlArray.push @tempPedido
        end
		
        #cerrar archivo
        file.close
        
        #modificar nuevo lastpedido
        @last_pedido.num = num
        @last_pedido.save
        
        
        @mensajeFinal = "Pedido procesado: #{num.to_s}"
        break
      else #sin nuevos pedidos
        @mensajeFinal = "No hay nuevos pedidos"
      end
    end
      
  end
  
  puts @mensajeFinal
  puts @tempPedido
  return Metodo_venta.venta(@tempPedido,@pedidoId)
  
  end
  
end