require 'product'

class Croissant < Product
  def self.prices
    PRICES
  end

  def self.code
    'CF'
  end

  private

  PRICES = {
    3 => 5.95,
    5 => 9.95,
    9 => 16.99
  }
end
