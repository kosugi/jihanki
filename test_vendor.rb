# -*- coding: utf-8 -*-

require 'test/unit'
require 'stringio'
require 'timeout'
require_relative 'vendor'

def ios(input)
  {:istream => StringIO.new(input, 'r'), :ostream => StringIO.new('', 'w')}
end

class Test_Vendor < Test::Unit::TestCase

  MOMENT = 0.01

  def test_available
    v = VendingMachine.new
    assert !v.available?

    v.add(Item.new '', 0, 0)
    assert !v.available?

    v.add(Item.new '', 1, 0)
    assert !v.available?

    v.add(Item.new '', 0, 1)
    assert !!v.available?
  end

  def test_get_item_index
    assert_equal -1, VendingMachine.new(ios('')).get_item_index
    assert_equal -1, VendingMachine.new(ios('0')).get_item_index
    assert_equal 0, VendingMachine.new(ios('1')).get_item_index
    assert_equal 1, VendingMachine.new(ios('2')).get_item_index
    assert_equal 8, VendingMachine.new(ios('9')).get_item_index
    assert_equal 9, VendingMachine.new(ios('10')).get_item_index
  end

  def test_get_item_by_index
    assert !VendingMachine.new().get_item_by_index(0)
    assert !VendingMachine.new().get_item_by_index(1)

    v = VendingMachine.new()
    v.add(Item.new '', 0, 0)
    assert !v.get_item_by_index(0)

    v = VendingMachine.new()
    v.add(Item.new '', 0, 0)
    v.add(Item.new '', 0, 1)
    assert !!v.get_item_by_index(0)
    assert !v.get_item_by_index(1)
  end

  def test_choose_item
    v = VendingMachine.new(ios('1'))
    begin
      timeout(MOMENT) {v.choose_item}
      assert false
    rescue Timeout::Error => ex
      assert true
    end

    v = VendingMachine.new(ios('1'))
    v.add(Item.new('', 0, 0))
    begin
      timeout(MOMENT) {v.choose_item}
      assert false
    rescue Timeout::Error => ex
      assert true
    end

    v = VendingMachine.new(ios('1'))
    i = Item.new('', 0, 1)
    v.add(i)
    timeout(MOMENT) {
      assert_equal i, v.choose_item
    }
  end

  def test_get_payment_amount
    assert !VendingMachine.new(ios(' ')).get_payment_amount
    assert !VendingMachine.new(ios('00')).get_payment_amount
    assert !VendingMachine.new(ios('01')).get_payment_amount
    assert !VendingMachine.new(ios('-1')).get_payment_amount
    assert_equal 0, VendingMachine.new(ios('0')).get_payment_amount
    assert_equal 0, VendingMachine.new(ios(' 0 ')).get_payment_amount
  end

  def test_ask_payment_amount
    v = VendingMachine.new(ios(' '))
    begin
      timeout(MOMENT) {v.choose_item}
      assert false
    rescue Timeout::Error => ex
      assert true
    end

    timeout(MOMENT) {assert_equal 0, VendingMachine.new(ios('0')).ask_payment_amount}
    timeout(MOMENT) {assert_equal 1, VendingMachine.new(ios('1')).ask_payment_amount}

    streams = ios(" \n2\n")
    v = VendingMachine.new(streams)
    timeout(MOMENT) {
      assert_equal 2, v.ask_payment_amount
      assert_equal 'Charge? Charge? ', streams[:ostream].string
    }
  end

  def test_transact_sortage
    streams = ios("1\n0\n")
    item = Item.new('', 1, 1)
    v = VendingMachine.new(streams)
    v.add(item)
    timeout(MOMENT) {
      v.transact
      assert streams[:ostream].string.match(/\bNumber\? Charge\? Shortage: 1 JPY\b/)
      assert_equal 1, item.stock
    }
  end

  def test_transact_too_much
    streams = ios("1\n2\n")
    item = Item.new('', 1, 1)
    v = VendingMachine.new(streams)
    v.add(item)
    timeout(MOMENT) {
      v.transact
      assert streams[:ostream].string.match(/\bNumber\? Charge\? Thanks, here's your change: 1 JPY\b/)
      assert_equal 0, item.stock
    }
  end

  def test_transact_exactly
    streams = ios("1\n1\n")
    item = Item.new('', 1, 1)
    v = VendingMachine.new(streams)
    v.add(item)
    timeout(MOMENT) {
      v.transact
      assert streams[:ostream].string.match(/\bNumber\? Charge\? Thanks, We've got exactly the amount of money we needed\b/)
      assert_equal 0, item.stock
    }
  end
end
