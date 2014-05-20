class SftpController < ApplicationController
  def index
  	respuesta = Metodo_sftp.index
  	puts respuesta
	session[:tmp_todo]= respuesta
	redirect_to pedidos_path
	
  end
  
  def list
	require 'xmlsimple'
	require 'net/sftp'
	
	@xmlArray = Array.new
	@fileArray = Array.new
	@numArray = Array.new
	
	@tempEntryName = ""
	@tempEntryNum = ""
	@tempXml = ""
	@tempPedido = ""
	
	@tempNumero = 1
	
	Net::SFTP.start('integra.ing.puc.cl', 'grupo4', :password => '498mdo') do |sftp|
		
		
			sftp.dir.glob("/home/grupo4/Pedidos/", "*.xml") do |entry|
				
				@tempEntryNum = entry.name[7..-5]
				@tempEntryName = entry.name
				
				session[:tmp_archivo]= @tempEntryName
				@fileArray.push @tempEntryName
				file = sftp.file.open("/home/grupo4/Pedidos/#{@tempEntryName}")
				
				@numArray.push @tempEntryNum
				
				file.gets
				@tempXml = file.gets
				
				@tempPedido = XmlSimple.xml_in(@tempXml)
				
				# agregar a session
				session[:tmp_pedido]= @tempPedido
				@xmlArray.push @tempPedido
				
				file.close
				
				#temporal hasta que se puedan borrar archivos
				#break
			end
	end
	
	#redirect_to pedidos_path
	
  end
end
