require "rubygems"

class Agregar_usuarios
  
  def self.actualizar
    u = BodegasVecinas.new
    u.username = "grupo7" 
    u.password = "integra7"
    u.save
  end
end