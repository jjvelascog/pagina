

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

#PROBANDO:
every 1.hour do
	runner "Metodo_twitter.publicarOfertas"
end

every 30.minutes do
	runner "Metodo_sftp.index"
end

every 1.day, :at => '1:32 am' do
	runner "Welcome.SetStock"
end
