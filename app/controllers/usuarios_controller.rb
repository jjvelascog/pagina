class UsuariosController < ApplicationController
  def actualizar
    BodegasVecinas.delete_all

    r = BodegasVecina.new
    r.username = "grupo7"
    r.password = "integra7"
    r.save
    
    
  end
end
