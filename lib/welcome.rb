class Welcome

  def self.CrearPromocion(precio, sku, hora_inicio, hora_fin)
    variable = Spree::Variant.find_by_sku(sku)
    producto = Spree::Product.find(variable.product_id)
    producto.put_on_sale(precio, calculator_type = "Spree::Calculator::DollarAmountSalePriceCalculator", all_variants = true, start_at = hora_inicio, end_at = hora_fin, enabled = true)
  end

  def self.CambiarStock(sku, c)
    variable = Spree::Variant.find_by_sku(sku)
    if variable.product_id
      producto = Spree::Product.find(variable.product_id) 
      producto.master.stock_items.first.update_column(:count_on_hand, c)
    end

  end

  def self.CambiarStockN(sku, c)
    mod= Item.where(sku: sku).first
    if mod
      modelo = mod.modelo
    
      producto = Spree::Product.find_by_name(modelo) 
      if producto
        producto.master.stock_items.first.update_column(:count_on_hand, c)
      end
    end
  end

  def self.AgregarStock(sku, c)
    mod = Item.where(sku: sku).first
    if mod
      modelo = mod.modelo
      producto = Spree::Product.find_by_name(modelo)
      if producto
        producto.master.stock_items.first.adjust_count_on_hand(c)
      end
    end
  end

  def self.Crear()
        p = Spree::Product.create :name => "prueba", :price => 100, :description => "", :sku => 1233556, :shipping_category_id => 1, :available_on => Time.now
        p.on_hand = 0
  end
  
  def self.SetStock
    Item.all.each do |item|
      self.ArreglarStock(item.sku)
    end
  end
  
  def self.ArreglarStock(sku)
      require 'almacen.rb'
      almacen = Almacen.new
      stock = almacen.get_stock(sku.to_s)
      
      reserva = Reserva.where(sku: sku.to_s)
      if(!reserva.empty?)
        total_reservas = reserva.sum(:cantidad)
      else
        total_reservas = 0
      end
      stock_disponible = stock-total_reservas
      self.CambiarStock(sku, [stock_disponible,0].max)
  end
  
end