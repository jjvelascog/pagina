 #every 1.minute do
 #  runner "Producto.metodo"
 #end

set :output, 'tmp/whenever.log'
set :environment, 'development' 

every 1.day, :at => '7:00 am' do
	runner "Producto.leeraccess"
end

every 1.day, :at => '7:15 am' do
	runner "Producto.actualizar"
end

every 1.day, :at => '7:35 am' do
	runner "Reserva.actualizar"
end

every 10.minutes do
	runner "Metodo_sftp.index"
end



#every 1.day, :at => '18:05 pm' do
#	runner "Metodo_sftp.index"
#end
