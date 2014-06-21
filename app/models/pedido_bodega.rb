require 'mongoid'

class Pedido_bodega

  include Mongoid::Document
  store_in collection: "pedidos_bodegas", database: "dw", session: "default"

  field :id_bodega, type: String
  field :fecha, type: Date
  
  embeds_many :producto_ocupados
  
  def ingresotot
    producto_ocupados.sum(:ingreso)
  end
end

