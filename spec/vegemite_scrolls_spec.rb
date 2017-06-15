require 'spec_helper'
require 'vegemite_scroll'

describe VegemiteScroll do
  describe "#prices" do
    it "returns supported packs and prices" do
      expect(VegemiteScroll.prices).to eq VegemiteScroll::PRICES
    end
  end

  describe "#code" do
    it "returns product code" do
      expect(VegemiteScroll.code).to eq 'VS5'
    end
  end
end
