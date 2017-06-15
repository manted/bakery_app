class Product
  def self.available_packs
    prices.keys
  end

  def self.price(pack)
    prices[pack] || 0.0
  end
end
