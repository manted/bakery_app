require 'vegemite_scroll'
require 'blueberry_muffin'
require 'croissant'

module BakeryApp
  # available products
  PRODUCTS = {
    VegemiteScroll.code => VegemiteScroll,
    BlueberryMuffin.code => BlueberryMuffin,
    Croissant.code => Croissant
  }

  # main method to run the app
  # need user to input order details
  def self.run
    puts 'Please type in order details:'
    puts 'Example order: 10 VS5 14 MB11 13 CF'
    order = STDIN.gets.chomp
    # verify input order
    # need to have complete item count and product code pairs
    order_params = order.split(' ')
    if order_params.length.odd? || order_params.empty?
      print_error_message('Invalid order. Are you missing an item count or a product code?')
      return
    end
    # process each order
    orders = order_params.each_slice(2).to_a
    process_orders(orders)
  end

  private

  # process each order
  def self.process_orders(orders)
    order_details = []
    orders.each do |order|
      item_count_string = order.first
      product_code = order.last
      # verify order's item count and product code
      # if valid, return valid pack combinations
      is_valid_order, item_count, product, valid_pack_combinations = verify_order(item_count_string, product_code)
      return unless is_valid_order
      pack_combination, cost = pick_best_pack_combination(product, valid_pack_combinations)
      order_detail = item_count, product, pack_combination, cost
      order_details << order_detail
    end
    # display final order details
    print_order_details(order_details)
  end

  # verify input order, return valid pack combinations
  # invalid order if:
  # - item count is not integer
  # - unavailable product code
  # - unsupported item count
  def self.verify_order(item_count_string, product_code)
    # verify item count
    item_count = item_count_string.to_i
    unless item_count.to_s == item_count_string
      print_error_message("Invalid item count: #{item_count_string}. It should be an integer.")
      return false, nil, nil, []
    end
    if item_count <= 0
      print_error_message("Invalid item count: #{item_count_string}. It should be greater than 0.")
      return false, nil, nil, []
    end
    # verify product code
    product = PRODUCTS[product_code]
    unless product
      print_error_message("Invalid product code: #{product_code}")
      return false, nil, nil, []
    end
    # check if item count is supported
    available_packs = product.available_packs
    valid_pack_combinations = pack_combinations(available_packs, item_count)
    if valid_pack_combinations.empty?
      print_error_message("Invalid item count #{item_count} for product #{product_code}")
      return false, nil, nil, []
    end
    return true, item_count, product, valid_pack_combinations 
  end

  # pick the combination that has the least cost and number of packs
  def self.pick_best_pack_combination(product, pack_combinations)
    cheapest_pack_combinations, cost = cheapest_combinations(product, pack_combinations)
    return smallest_combination(cheapest_pack_combinations), cost
  end

  # recursive method to find all pack combinations for item count
  # assuming available_packs in sorted in ascending order
  def self.pack_combinations(available_packs, item_count, valid_combinations = [], partial = [])
    s = partial.inject(0, :+)
    # add partial to result if the partial sum equals to target number
    valid_combinations << partial if s == item_count
     # no need to continue if reach the number
    return if s > item_count
    current_pack = partial.last || 0
    # no need to check smaller numbers as they will cover themselves
    remaining = available_packs.select{|x| x >= current_pack}
    remaining.each do |n|
      pack_combinations(remaining, item_count, valid_combinations, partial + [n])
    end
    valid_combinations
  end

  # returns the pack combinations with the cheapest total cost of a product
  def self.cheapest_combinations(product, combinations)
    cheapest_total_cost = Float::INFINITY
    cheapest_combinations = []
    combinations.each do |combination|
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
    return cheapest_combinations, cheapest_total_cost
  end

  # returns the combination with the fewest number of packs
  def self.smallest_combination(combinations)
    pack_counts = combinations.map{|c| c.length}
    fewest_pack_index = pack_counts.each_with_index.min.last
    combinations[fewest_pack_index]
  end

  # display methods

  # display each order
  def self.print_order_details(order_details)
    order_details.each do |order_detail|
      item_count, product, pack_combination, cost = order_detail
      print_order(product, item_count, pack_combination, cost)
    end
  end

  # display order in readable format
  def self.print_order(product, item_count, pack_combination, cost)
    puts '-' * 40
    puts "Order: #{item_count} #{product.code}"
    puts "Total cost: $#{cost}"
    used_packs = pack_combination.uniq
    used_packs.each do |pack|
      puts "#{pack_combination.count(pack)} x #{pack} $#{product.price(pack)}"
    end
  end

  # display error message
  def self.print_error_message(message)
    puts 'ERROR: ' + message
  end
end
