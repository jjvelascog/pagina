require 'mongoid'

class Pedido_spree

  include Mongoid::Document
  store_in collection: "pedidos_sprees", database: "dw", session: "default"

  field :nombre, type: String
  field :fecha, type: Date
  field :direccion, type: String
  
  embeds_many :producto_ocupados
  
  def ingresotot
    producto_ocupados.sum(:ingreso)
  end
end
