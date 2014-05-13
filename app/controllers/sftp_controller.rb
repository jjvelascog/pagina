class SftpController < ApplicationController
  def index
	require 'xmlsimple'
	require 'net/sftp'
	
	@xmlArray = Array.new
	@fileArray = Array.new
	
	@tempEntryName = ""
	@tempXml = ""
	@tempPedido = ""
	
	Net::SFTP.start('integra.ing.puc.cl', 'grupo4', :password => '498mdo') do |sftp|
		
		
		sftp.dir.glob("/home/grupo4/Pedidos/", "*.xml") do |entry|
			
			@tempEntryName = entry.name
			
			@fileArray.push @tempEntryName
			file = sftp.file.open("/home/grupo4/Pedidos/#{@tempEntryName}")
			
			file.gets
			@tempXml = file.gets
			
			@tempPedido = XmlSimple.xml_in(@tempXml)
			
			# agregar a session
			session[:tmp_pedido]= @tempPedido
			@xmlArray.push @tempPedido
			
			file.close
			
			#temporal hasta que se puedan borrar archivos
			break
		end
	end
	
	redirect_to pedidos_path
	
  end
end
