require "test/test_helper"

module Payday
  class LineItemTest < Test::Unit::TestCase
    test "initializing with a price" do
      li = LineItem.new(:price => BigDecimal.new("20"))
      assert_equal BigDecimal.new("20"), li.price
    end
  
    test "initializing with a quantity" do
      li = LineItem.new(:quantity => 30)
      assert_equal BigDecimal.new("30"), li.quantity
    end
  
    test "initializing with a description" do
      li = LineItem.new(:description => "12 Pairs of Pants")
      assert_equal "12 Pairs of Pants", li.description
    end
    
    test "that amount returns the correct amount" do
      li = LineItem.new(:price => 10, :quantity => 12)
      assert_equal BigDecimal.new("120"), li.amount
    end
  end
end