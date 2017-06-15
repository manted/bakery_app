require 'spec_helper'
require 'product'

describe Product do
  describe "#available_packs" do
    it "returns all keys in prices hash" do
      packs = "packs"
      expect(Product).to receive_message_chain(:prices, :keys).and_return(packs)
      expect(Product.available_packs).to eq packs
    end
  end

  describe "#price" do
    it "returns the price of the given pack" do
      pack = rand(5)
      price = rand(10)
      expect(Product).to receive_message_chain(:prices, :[]).with(pack).and_return(price)
      expect(Product.price(pack)).to eq price
    end

    it "returns 0.0 if the given pack is not supported" do
      pack = rand(5)
      expect(Product).to receive_message_chain(:prices, :[]).with(pack).and_return(nil)
      expect(Product.price(pack)).to eq 0.0
    end
  end
end
