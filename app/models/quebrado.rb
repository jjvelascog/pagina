require 'mongoid'

class Quebrado

  include Mongoid::Document
  store_in collection: "quebrados", database: "dw", session: "default"

  field :sku, type: Integer
  field :cantidad, type: Integer
  field :PedidoId, type: Integer
end
