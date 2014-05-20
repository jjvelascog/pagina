class UsuariosController < ApplicationController
  def actualizar
    BodegasVecinas.delete_all

    r = BodegasVecinas.new
    r.username = "grupo7"
    r.password = "a502ccca911d5c5f2a617de180cbcdc0626d6204"
    r.save
    
    r = BodegasVecinas.new
    r.username = "grupo3"
    r.password = "05452d511826a15ba32d6fc4f3562ea75b16db8f"
    r.save
    
    r = BodegasVecinas.new
    r.username = "grupo9"
    r.password = "795f5a03cad01447898fb5861de0d0af6115b0c1"
    r.save
    
    r = BodegasVecinas.new
    r.username = "grupo6"
    r.password = "ebdf1bdb858ced98b4adef024c3ec86fbdc141c9"
    r.save
    
    r = BodegasVecinas.new
    r.username = "grupo5"
    r.password = "675af2de40aa875fb8877a7afa3a11e0989ae496"
    r.save
    
    r = BodegasVecinas.new
    r.username = "grupo1"
    r.password = "6d32b1c68191c32b0d8203aae385b77ded18ed49"
    r.save
  end
end
