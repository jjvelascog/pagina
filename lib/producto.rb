class Producto
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
  
  end
  
end

