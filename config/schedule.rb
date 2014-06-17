

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



every 1.day, :at => '18:32 pm' do
	runner "Producto.leeraccess"
end

every 1.day, :at => '18:34 pm' do
	runner "Producto.actualizar"
end

every 1.day, :at => '18:39 pm' do
	runner "Reserva.actualizar"
end