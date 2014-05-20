class LastPedido < ActiveRecord::Base

	def self.leersftp

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
				session[:tmp_pedidoid]= num.to_s
				@fileArray.push num.to_s
				
				#abrir archivo
				file = sftp.file.open("/home/grupo4/Pedidos/pedido_#{num.to_s}.xml")
				
				file.gets
				@tempXml = file.gets
			
				#transformar xml
				@tempPedido = XmlSimple.xml_in(@tempXml)
				
				#agregar pedido a session (pasar a sgte metodo)
				session[:tmp_pedido]= @tempPedido
				@xmlArray.push @tempPedido
				
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
	redirect_to pedidos_path

	end

	


end
