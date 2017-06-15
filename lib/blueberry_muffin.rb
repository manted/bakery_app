require 'product'

class BlueberryMuffin < Product
  def self.prices
    PRICES
  end

  def self.code
    'MB11'
  end  

  private

  PRICES = {
    2 => 9.95,
    5 => 16.95,
    8 => 24.95
  }
end
