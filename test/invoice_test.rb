require "test/test_helper"

module Payday
  class InvoiceTest < Test::Unit::TestCase
    test "that setting values through the options hash on initialization works" do
      i = Invoice.new(:invoice_number => 20, :bill_to => "Here", :ship_to => "There",
          :notes => "These are some notes.",
          :line_items => [LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")],
          :tax_rate => 12.5, :tax_description => "Local Sales Tax, 12.5%")
          
      assert_equal 20, i.invoice_number
      assert_equal "Here", i.bill_to
      assert_equal "There", i.ship_to
      assert_equal "These are some notes.", i.notes
      assert_equal "Shirts", i.line_items[0].description
      assert_equal BigDecimal.new("12.5"), i.tax_rate
      assert_equal "Local Sales Tax, 12.5%", i.tax_description
    end
        
    test "that subtotal totals up all of the line items in an invoice correctly" do
      i = Invoice.new
      
      # $100 in Pants
      i.line_items << LineItem.new(:price => 20, :quantity => 5, :description => "Pants")
      
      # $30 in Shirts
      i.line_items << LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")
      
      # $1000 in Hats
      i.line_items << LineItem.new(:price => 5, :quantity => 200, :description => "Hats")
      
      assert_equal BigDecimal.new("1130"), i.subtotal
    end
    
    test "that tax returns the correct tax amount, rounded to two decimal places" do
      i = Invoice.new(:tax_rate => 0.1)
      i.line_items << LineItem.new(:price => 20, :quantity => 5, :description => "Pants")
      
      assert_equal(BigDecimal.new("10"), i.tax)
    end
    
    test "that the total for this invoice calculates correctly" do
      i = Invoice.new(:tax_rate => 0.1)
      
      # $100 in Pants
      i.line_items << LineItem.new(:price => 20, :quantity => 5, :description => "Pants")
      
      # $30 in Shirts
      i.line_items << LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")
      
      # $1000 in Hats
      i.line_items << LineItem.new(:price => 5, :quantity => 200, :description => "Hats")
      
      assert_equal BigDecimal.new("1243"), i.total
    end
    
    test "rendering to pdf" do
      i = Invoice.new(:tax_rate => 0.1, :notes => "These are some crazy awesome notes!", :invoice_number => 12,
          :bill_to => "Alan Johnson\n101 This Way\nSomewhere, SC 22222", :ship_to => "Frank Johnson\n101 That Way\nOther, SC 22229")
      
      3.times do
        i.line_items << LineItem.new(:price => 20, :quantity => 5, :description => "Pants")
        i.line_items << LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")
        i.line_items << LineItem.new(:price => 5, :quantity => 200, :description => "Hats")
      end
      
      i.render_to_pdf
    end
  end
end