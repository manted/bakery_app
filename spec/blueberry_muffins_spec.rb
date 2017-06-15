require 'spec_helper'
require 'blueberry_muffin'

describe BlueberryMuffin do
  describe "#prices" do
    it "returns supported packs and prices" do
      expect(BlueberryMuffin.prices).to eq BlueberryMuffin::PRICES
    end
  end

  describe "#code" do
    it "returns product code" do
      expect(BlueberryMuffin.code).to eq 'MB11'
    end
  end
end
