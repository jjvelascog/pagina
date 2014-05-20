class Quebrados
  include Mongoid::Document
  field :sku, type: Integer
  field :cantidad, type: Integer
  field :PedidoId, type: Integer
end
