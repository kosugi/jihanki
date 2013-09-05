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
  def initialize(istream: STDIN, ostream: STDOUT)
    @is = istream
    @os = ostream
    @items = {}
  end

  def add(item)
    @items[item.name] = item
  end

  def show_items
    @os.printf "\n"
    @items.each_with_index do |(name, item), n|
      @os.printf(
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
      @os.printf "Number? "
      n = @is.gets.to_i - 1
      if (0...@items.count).member? n
        item = @items.values[n]
        return item if item.stock.nonzero?
      end
    end
  end

  def receive_payment_for(item)
    loop do
      @os.printf "Charge? "
      s = @is.gets.strip
      n = s.to_i
      return n if s === n.to_s and 0 <= n
    end
  end

  def transact
    item = choose_item
    m = receive_payment_for item
    if m < item.price
      @os.printf "Shortage: %d JPY. Try again\n", item.price - m
    elsif m > item.price
      @os.printf "Thanks, here's your change: %d JPY\n", m - item.price
      item.stock -= 1
    else
      @os.printf "Thanks, We've got exactly the amount of money we needed.\n"
      item.stock -= 1
    end
  end

  def available?
    @items.inject(0) {|stock, (name, item)| stock + item.stock}.nonzero?
  end

  def boot
    @os.printf "Hello\n"
    while available?
      transact
    end
    @os.printf "No stock. Please try again tomorrow.\n"
  end
end
