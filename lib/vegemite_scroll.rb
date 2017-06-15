require 'product'

class VegemiteScroll < Product
  def self.prices
    PRICES
  end

  def self.code
    'VS5'
  end

  private

  PRICES = {
    3 => 6.99,
    5 => 8.99
  }
end
