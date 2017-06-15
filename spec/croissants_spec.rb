require 'spec_helper'
require 'croissant'

describe Croissant do
  describe "#prices" do
    it "returns supported packs and prices" do
      expect(Croissant.prices).to eq Croissant::PRICES
    end
  end

  describe "#code" do
    it "returns product code" do
      expect(Croissant.code).to eq 'CF'
    end
  end
end
