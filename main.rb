# -*- coding: utf-8 -*-

class Item
  attr_reader :name
  attr_accessor :price, :stock

  def initialize(name, price, stock)
    @name = name
    @price = price
    @stock = stock
  end
end

class VendingMachine
  def initialize(istream)
    @istream = istream
    @items = {}
  end

  def add(item)
    @items[item.name] = item
  end

  def show_items
    printf "\n"
    @items.each_with_index do |(name, item), n|
      printf(
        "%2d. %-20s (%3d JPY) %s\n",
        n + 1,
        name,
        item.price,
        item.stock.zero? ? '[sold out]' : '')
    end
  end

  def choose_item
    loop do
      show_items
      printf "Number? "
      n = @istream.gets.to_i - 1
      if (0...@items.count).member? n
        item = @items.values[n]
        return item if item.stock.nonzero?
      end
    end
  end

  def receive_payment_for(item)
    loop do
      printf "Charge? "
      s = @istream.gets.strip
      n = s.to_i
      return n if s === n.to_s and 0 <= n
    end
  end

  def transact
    item = choose_item
    m = receive_payment_for item
    if m < item.price
      printf "Shortage: %d JPY. Try again\n", item.price - m
    elsif m > item.price
      printf "Thanks, here's your change: %d JPY\n", m - item.price
      item.stock -= 1
    else
      printf "Thanks, We've got exactly the amount of money we needed.\n"
      item.stock -= 1
    end
  end

  def available?
    @items.inject(0) {|stock, (name, item)| stock + item.stock}.nonzero?
  end

  def boot
    printf "Hello\n"
    while available?
      transact
    end
    printf "No stock. Please try again tomorrow.\n"
  end
end

vendor = VendingMachine.new(STDIN)
vendor.add Item.new('Orange juice', 98, 1)
vendor.add Item.new('Pepsi NEX', 120, 2)
vendor.add Item.new('Sprite', 150, 0)
vendor.add Item.new('Evian', 200, 3)
vendor.add Item.new('Simle', 0, 1)
vendor.boot
