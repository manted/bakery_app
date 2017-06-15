require 'spec_helper'
require 'bakery_app'

describe BakeryApp do
  describe "#run" do
    before(:each) do
      allow(STDOUT).to receive(:puts)
    end

    it "returns if there is odd number of input params" do
      inputs = (['input'] * (rand(3) * 2 + 1)).join(' ')
      allow(STDIN).to receive_message_chain(:gets, :chomp).and_return(inputs)
      expect(BakeryApp).to receive(:print_error_message).with('Invalid order. Are you missing an item count or a product code?')
      BakeryApp.run
    end

    it "returns if there is no input params" do
      inputs = ''
      allow(STDIN).to receive_message_chain(:gets, :chomp).and_return(inputs)
      expect(BakeryApp).to receive(:print_error_message).with('Invalid order. Are you missing an item count or a product code?')
      BakeryApp.run
    end

    it "calls process_orders with order details" do
      inputs = double('inputs')
      allow(STDIN).to receive_message_chain(:gets, :chomp).and_return(inputs)
      order_params = double('order params')
      allow(order_params).to receive_message_chain(:length, :odd?).and_return(false)
      allow(order_params).to receive(:empty?).and_return(false)
      expect(inputs).to receive(:split).with(' ').and_return(order_params)
      orders = 'orders'
      expect(order_params).to receive_message_chain(:each_slice, :to_a).with(2).with(no_args).and_return(orders)
      expect(BakeryApp).to receive(:process_orders).with(orders)
      BakeryApp.run
    end
  end

  describe "#process_orders" do
    it "returns if there is any invalid order" do
      orders = []
      order_count = rand(1..3)
      invalid_order_index = rand(order_count)
      (0..order_count - 1).each do |i|
        item_count = rand(5)
        item_count_string = "#{item_count}"
        product_code = "code #{i}"
        order = [item_count_string, product_code]
        orders << order
        if i == invalid_order_index
          expect(BakeryApp).to receive(:verify_order).with(item_count_string, product_code).and_return([false, nil, nil, nil])
        elsif i < invalid_order_index
          product = 'product'
          valid_pack_combinations = 'valid pack combinations'
          cost = 'cost'
          expect(BakeryApp).to receive(:verify_order).with(item_count_string, product_code).and_return([true, item_count, product, valid_pack_combinations])
          best_combination = 'best combination'
          expect(BakeryApp).to receive(:pick_best_pack_combination).with(product, valid_pack_combinations).and_return([best_combination, cost])
        end
      end
      expect(BakeryApp).not_to receive(:print_order_details)
      BakeryApp.process_orders(orders)
    end

    it "calls print_order_details if all orders are valid" do
      orders = []
      order_details = []
      order_count = rand(1..3)
      (0..order_count - 1).each do |i|
        item_count = rand(5)
        item_count_string = "#{item_count}"
        product_code = "code #{i}"
        order = [item_count_string, product_code]
        orders << order
        product = 'product'
        valid_pack_combinations = 'valid pack combinations'
        cost = 'cost'
        expect(BakeryApp).to receive(:verify_order).with(item_count_string, product_code).and_return([true, item_count, product, valid_pack_combinations])
        best_combination = 'best combination'
        expect(BakeryApp).to receive(:pick_best_pack_combination).with(product, valid_pack_combinations).and_return([best_combination, cost])
        order_details << [item_count, product, best_combination, cost]
      end
      expect(BakeryApp).to receive(:print_order_details).with(order_details)
      BakeryApp.process_orders(orders)
    end
  end

  describe "#verify_order" do
    it "returns false if item_count is not integer" do
      item_count_string = 'd'
      product_code = 'code'
      expect(BakeryApp).to receive(:print_error_message).with("Invalid item count: #{item_count_string}. It should be an integer.")
      is_valid_order, item_count, product, pack_combinations = BakeryApp.verify_order(item_count_string, product_code)
      expect(is_valid_order).to be false
    end

    it "returns false if item_count <= 0" do
      item_count_string = "#{0 - rand(3)}"
      product_code = 'code'
      expect(BakeryApp).to receive(:print_error_message).with("Invalid item count: #{item_count_string}. It should be greater than 0.")
      is_valid_order, item_count, product, pack_combinations = BakeryApp.verify_order(item_count_string, product_code)
      expect(is_valid_order).to be false
    end

    it "returns false if invalid product code" do
      item_count_string = "#{rand(1..5)}"
      product_code = 'code'
      expect(BakeryApp::PRODUCTS).to receive(:[]).with(product_code).and_return(nil)
      expect(BakeryApp).to receive(:print_error_message).with("Invalid product code: #{product_code}")
      is_valid_order, item_count, product, pack_combinations = BakeryApp.verify_order(item_count_string, product_code)
      expect(is_valid_order).to be false
    end

    it "returns false if can not find pack combinations that meet item count" do
      item_count = rand(1..5)
      item_count_string = "#{item_count}"
      product_code = 'code'
      product = double('product')
      expect(BakeryApp::PRODUCTS).to receive(:[]).with(product_code).and_return(product)
      available_packs = 'available packs'
      expect(product).to receive(:available_packs).and_return(available_packs)
      expect(BakeryApp).to receive(:pack_combinations).with(available_packs, item_count).and_return([])
      expect(BakeryApp).to receive(:print_error_message).with("Invalid item count #{item_count} for product #{product_code}")
      is_valid_order, item_count, product, pack_combinations = BakeryApp.verify_order(item_count_string, product_code)
      expect(is_valid_order).to be false
    end

    it "returns true, item_count, product and valid_pack_combinations if valid order" do
      item_count = rand(1..5)
      item_count_string = "#{item_count}"
      product_code = 'code'
      product = double('product')
      expect(BakeryApp::PRODUCTS).to receive(:[]).with(product_code).and_return(product)
      available_packs = 'available packs'
      expect(product).to receive(:available_packs).and_return(available_packs)
      pack_combinations = 'pack combinations'
      expect(BakeryApp).to receive(:pack_combinations).with(available_packs, item_count).and_return(pack_combinations)
      results = BakeryApp.verify_order(item_count_string, product_code)
      expect(results).to eq [true, item_count, product, pack_combinations]
    end
  end

  describe "#pick_best_pack_combination" do
    before(:each) do
      @product = 'product'
      @combinations = 'combinations'
      @cheapest_combinations = 'cheapest combinations'
      @cost = 'cost'
    end

    it "finds pack combinations with the least total cost" do
      expect(BakeryApp).to receive(:cheapest_combinations).with(@product, @combinations).and_return([@cheapest_combinations, @cost])
      allow(BakeryApp).to receive(:smallest_combination).with(@cheapest_combinations)
      BakeryApp.pick_best_pack_combination(@product, @combinations)
    end

    it "returns pack combination with the least number of packs from the cheapest combinations" do
      best_combination = 'best combination'
      expect(BakeryApp).to receive(:cheapest_combinations).with(@product, @combinations).and_return([@cheapest_combinations, @cost])
      expect(BakeryApp).to receive(:smallest_combination).with(@cheapest_combinations).and_return(best_combination)
      expect(BakeryApp.pick_best_pack_combination(@product, @combinations)).to eq [best_combination, @cost]
    end
  end

  describe "#pack_combinations" do
    before(:each) do
      @packs = [3, 5, 9]
    end

    it "returns empty array if there is no valid combination" do
      expect(BakeryApp.pack_combinations(@packs, 1)).to eq []
      expect(BakeryApp.pack_combinations(@packs, 2)).to eq []
    end

    it "returns all valid combinations for item count" do
      combinations = [
        [3, 3, 3, 3, 3],
        [3, 3, 9],
        [5, 5, 5]
      ]
      results = BakeryApp.pack_combinations(@packs, 15)
      combinations.each do |combination|
        expect(results).to include combination
      end
    end

    it "returns array of unique combinations" do
      results = BakeryApp.pack_combinations([1, 2, 3], 6)
      sorted_results = results.map{|r| r.sort}
      sorted_results.uniq!
      expect(sorted_results).to eq results
    end
  end

  describe "#cheapest_pack_combinations" do
    it "returns the cheapest combinations and total cost" do
      prices = {
        1 => rand(0.1..2.0),
        2 => rand(2.1..4.0),
        3 => rand(4.1..6.0)
      }
      product = double('product')
      prices.each do |pack, price|
        allow(product).to receive(:price).with(pack).and_return(price)
      end
      cheapest_total_cost = Float::INFINITY
      cheapest_combinations = []
      packs = prices.keys
      combinations = []
      (1..3).each do
        combination = []
        rand(1..3).times do
          combination += [packs.sample] * rand(3)
        end
        combinations << combination
        total_cost = combination.inject(0) {|sum, pack| (sum + product.price(pack)).round(2)}
        if total_cost < cheapest_total_cost
          # found new cheapest combination
          cheapest_total_cost = total_cost
          cheapest_combinations = [combination]
        elsif total_cost == cheapest_total_cost
          # found combination with the cheapest cost
          cheapest_combinations << combination
        end
      end
      expect(BakeryApp.cheapest_combinations(product, combinations)).to eq [cheapest_combinations, cheapest_total_cost]
    end
  end

  describe "#smallest_combination" do
    it "returns the combination with the least number of packs" do
      fewest_pack_count = rand(1..5)
      combinations_count = rand(3..5)
      smallest_combination_index = rand(combinations_count)
      combinations = []
      smallest_combination = nil
      (0..combinations_count - 1).each do |i|
        if i == smallest_combination_index
          combination = (0..fewest_pack_count - 1).map{|x| rand(1..3)}
          smallest_combination = combination
        else
          combination = (0..fewest_pack_count + rand(3)).map{|x| rand(1..3)}
        end
        combinations << combination
      end
      expect(BakeryApp.smallest_combination(combinations)).to eq smallest_combination
    end
  end

  describe "#print_order_details" do
    it "calls print_order for each order" do
      order_details = []
      rand(1..3).times do
        item_count = 'item count'
        product = 'product'
        pack_combination = 'pack combination'
        cost = 'cost'
        order_detail = [item_count, product, pack_combination, cost]
        expect(BakeryApp).to receive(:print_order).with(product, item_count, pack_combination, cost)
        order_details << order_detail
      end
      BakeryApp.print_order_details(order_details)
    end
  end
end
