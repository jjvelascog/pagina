require 'mongoid'

class Pedido_cliente

  include Mongoid::Document
  store_in collection: "pedidos_clientes", database: "dw", session: "default"

  field :rut, type: String
  field :pedidoId, type: Integer
  field :fecha, type: Date
  field :direccion, type: String
  
  embeds_many :producto_ocupados
  embeds_many :reserva_ocupadas
  embeds_many :quebrados
  
  def ingresotot
    producto_ocupados.sum(:ingreso)
  end
end
