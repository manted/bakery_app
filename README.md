# Bakery

Given a customer order, this app determines the cost and pack breakdown for each product. To save on shipping space each order should contain the minimal number of packs.

# Input

Each order has a series of pairs with each pair containing the number of items followed by the product code. An example input:
10 VS5 14 MB11 13 CF

# Output

A successfully passing test(s) that demonstrates the following output:

```
10 VS5
Total cost: $17.98
2 x 5 $8.99

14 MB11
Total cost: $53.8
2 x 2 $9.95
2 x 5 $16.95

13 CF
Total cost: $25.85
2 x 5 $9.95 
1 x 3 $5.95
```

# Assumptions
- For a required item count, try to find pack breakdown with the least total cost. For pack breakdown with same total cost, use the one with the fewest number of packs
- If input order has multiple pairs with same production code, they are treated as seperate orders. For example, `13 CF 13 CF` has 2 orders, each of them requires 13 items of croissant.
- All input params need to be valid in order to complete the order. That means, item counts should be possitive integers, product code should be supported and there must be at least one pack breakdown for the item count of each product.

# How to use it

Bakery App requires ruby and bundler to be installed. Before you begin; install the dependencies by running `bundle`.
Once the dependencies have been installed you'll have a few commands available:

- `bundle exec rake`  : Will attempt to run the application.
- `bundle exec rspec` : Runs the test suite.
