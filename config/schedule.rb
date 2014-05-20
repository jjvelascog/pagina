 #every 1.minute do
 #  runner "Producto.metodo"
 #end

set :output, 'tmp/whenever.log'
set :environment, 'development' 

every 1.day, :at => '7:00 am' do
	runner "Producto.leeraccess"
end

every 1.day, :at => '7:10 am' do
	runner "Producto.actualizar"
end

every 1.day, :at => '7:30 am' do
	runner "Reserva.actualizar"
end

#every 10.minutes do
	#runner #LLAMAR FUNCIÓN sftp
#end



every 1.day, :at => '16:06 pm' do
	runner "Producto.leeraccess"
end

every 1.day, :at => '16:07 pm' do
	runner "Producto.actualizar"
end

every 1.day, :at => '13:32 pm' do
	runner "Producto.actualizar"
	runner "Producto.metodo"
end