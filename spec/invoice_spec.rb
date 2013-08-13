require 'spec_helper'

module Payday
  describe Invoice do

    it "should be able to be initalized with a hash of options" do
      i = Invoice.new(:invoice_number => 20, :bill_to => "Here", :ship_to => "There",
          :notes => "These are some notes.",
          :line_items => [LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")],
          :shipping_rate => 15.00, :shipping_description => "USPS Priority Mail:",
          :tax_rate => 0.125, :tax_description => "Local Sales Tax, 12.5%")

      expect(i.invoice_number).to eq(20)
      expect(i.bill_to).to eq("Here")
      expect(i.ship_to).to eq("There")
      expect(i.notes).to eq("These are some notes.")
      expect(i.line_items[0].description).to eq("Shirts")
      expect(i.shipping_rate).to eq(BigDecimal.new("15.00"))
      expect(i.shipping_description).to eq("USPS Priority Mail:")
      expect(i.tax_rate).to eq(BigDecimal.new("0.125"))
      expect(i.tax_description).to eq("Local Sales Tax, 12.5%")
    end

    it "should total all of the line items into a subtotal correctly" do
      i = Invoice.new

      # $100 in Pants
      i.line_items << LineItem.new(:price => 20, :quantity => 5, :description => "Pants")

      # $30 in Shirts
      i.line_items << LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")

      # $1000 in Hats
      i.line_items << LineItem.new(:price => 5, :quantity => 200, :description => "Hats")

      expect(i.subtotal).to eq(BigDecimal.new("1130"))
    end

    it "should calculate the correct tax amount, rounded to two decimal places" do
      i = Invoice.new(:tax_rate => 0.1, :tax2_rate => 0.5)
      i.line_items << LineItem.new(:price => 20, :quantity => 5, :description => "Pants")

      expect(i.tax).to eq(BigDecimal.new("10"))
      expect(i.tax2).to eq(BigDecimal.new("50"))
    end

    it "shouldn't apply taxes to invoices with a subtotal of 0 or a negative amount" do
      i = Invoice.new(:tax_rate => 0.1)
      i.line_items << LineItem.new(:price => -1, :quantity => 100, :description => "Negative Priced Pants")

      expect(i.tax).to eq(BigDecimal.new("0"))
    end

    it "should calculate the total for an invoice correctly" do
      i = Invoice.new(:tax_rate => 0.1, :tax2_rate => 0.2)

      # $100 in Pants
      i.line_items << LineItem.new(:price => 20, :quantity => 5, :description => "Pants")

      # $30 in Shirts
      i.line_items << LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")

      # $1000 in Hats
      i.line_items << LineItem.new(:price => 5, :quantity => 200, :description => "Hats")

      expect(i.total).to eq(BigDecimal.new("1469"))
    end

    it "is overdue when it's past date and unpaid" do
      i = Invoice.new(:due_at => Date.today - 1)
      expect(i.overdue?).to eq(true)
    end

    it "isn't overdue when past due date and paid" do
      i = Invoice.new(:due_at => Date.today - 1, :paid_at => Date.today)
      expect(i.overdue?).not_to eq(true)
    end

    it "is overdue when due date is a time before the current date" do
      i = Invoice.new(:due_at => Time.parse("Jan 1 14:33:20 GMT 2011"))
      expect(i.overdue?).to eq(true)
    end

    it "shouldn't be paid when not marked paid" do
      i = Invoice.new
      expect(i.paid?).not_to eq(true)
    end

    it "should be paid when marked as paid" do
      i = Invoice.new(:paid_at => Date.today)
      expect(i.paid?).to eq(true)
    end

    it "should be able to iterate over details" do
      i = Invoice.new(:invoice_details => [["Test", "Yes"], ["Awesome", "Absolutely"]])
      details = []
      i.each_detail do |key, value|
        details << [key, value]
      end

      expect(details.length).to eq(2)
      expect(details).to include(["Test", "Yes"])
      expect(details).to include(["Awesome", "Absolutely"])
    end

    it "should be able to iterate through invoice_details as a hash" do
      i = Invoice.new(:invoice_details => {"Test" => "Yes", "Awesome" => "Absolutely"})
      details = []
      i.each_detail do |key, value|
        details << [key, value]
      end

      expect(details.length).to eq(2)
      expect(details).to include(["Test", "Yes"])
      expect(details).to include(["Awesome", "Absolutely"])
    end

    describe "rendering" do
      before do
        Dir.mkdir("tmp") unless File.exists?("tmp")
        Config.default.reset
      end

      it "should be able to render to a file" do
        File.unlink("tmp/testing.pdf") if File.exists?("tmp/testing.pdf")

        i = Invoice.new(:tax_rate => 0.1, :notes => "These are some crazy awesome notes!", :invoice_number => 12,
            :due_at => Date.civil(2011, 1, 22), #:paid_at => Date.civil(2012, 2, 22),
            :bill_to => "Alan Johnson\n101 This Way\nSomewhere, SC 22222",
            :ship_to => "Frank Johnson\n101 That Way\nOther, SC 22229",
            :invoice_details => {"Ordered By:" => "Alan Johnson", "Paid By:" => "Dude McDude"})

        Payday::Config.default.company_details = "10 This Way\nManhattan, NY 10001\n800-111-2222\nawesome@awesomecorp.com"

        30.times do
          i.line_items << LineItem.new(:price => 20, :quantity => 5, :description => "Pants")
          i.line_items << LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")
          i.line_items << LineItem.new(:price => 5, :quantity => 200, :description => "Hats")
        end

        i.render_pdf_to_file("tmp/testing.pdf")

        expect(File.exists?("tmp/testing.pdf")).to eq(true)
      end

      it "should be able to render to a string" do
        i = Invoice.new(:tax_rate => 0.1, :notes => "These are some crazy awesome notes!", :invoice_number => 12,
          :due_at => Date.civil(2011, 1, 22), :paid_at => Date.civil(2012, 2, 22),
          :bill_to => "Alan Johnson\n101 This Way\nSomewhere, SC 22222", :ship_to => "Frank Johnson\n101 That Way\nOther, SC 22229")

        3.times do
          i.line_items << LineItem.new(:price => 20, :quantity => 5, :description => "Pants")
          i.line_items << LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")
          i.line_items << LineItem.new(:price => 5, :quantity => 200.0, :description => "Hats")
        end

        expect(i.render_pdf).not_to eq(nil)
      end

      it "should be able to render with an svg logo" do
        Payday::Config.default.invoice_logo = { :filename => "assets/tiger.svg", :size => "100x100" }
        i = Invoice.new(:tax_rate => 0.1, :notes => "These are some crazy awesome notes!", :invoice_number => 12,
          :due_at => Date.civil(2011, 1, 22), :paid_at => Date.civil(2012, 2, 22),
          :bill_to => "Alan Johnson\n101 This Way\nSomewhere, SC 22222", :ship_to => "Frank Johnson\n101 That Way\nOther, SC 22229")

        3.times do
          i.line_items << LineItem.new(:price => 20, :quantity => 5, :description => "Pants")
          i.line_items << LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")
          i.line_items << LineItem.new(:price => 5, :quantity => 200.0, :description => "Hats")
        end

        i.render_pdf_to_file("tmp/svg.pdf")

        expect(i.render_pdf).not_to eq(nil)
      end
    end
  end
end
