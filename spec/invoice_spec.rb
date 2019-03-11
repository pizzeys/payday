require "spec_helper"

module Payday
  describe Invoice do

    it "should be able to be initalized with a hash of options" do
      i = Invoice.new(invoice_number: 20, bill_to: "Here", ship_to: "There",
          notes: "These are some notes.",
          line_items:
            [LineItem.new(price: 10, quantity: 3, description: "Shirts")],
          shipping_rate: 15.00, shipping_description: "USPS Priority Mail:",
          tax_rate: 0.125, tax_description: "Local Sales Tax, 12.5%",
          invoice_date: Date.civil(1993, 4, 12))

      expect(i.invoice_number).to eq(20)
      expect(i.bill_to).to eq("Here")
      expect(i.ship_to).to eq("There")
      expect(i.notes).to eq("These are some notes.")
      expect(i.line_items[0].description).to eq("Shirts")
      expect(i.shipping_rate).to eq(BigDecimal("15.00"))
      expect(i.shipping_description).to eq("USPS Priority Mail:")
      expect(i.tax_rate).to eq(BigDecimal("0.125"))
      expect(i.tax_description).to eq("Local Sales Tax, 12.5%")
      expect(i.invoice_date).to eq(Date.civil(1993, 4, 12))
    end

    it "should total all of the line items into a subtotal correctly" do
      i = Invoice.new

      # $100 in Pants
      i.line_items << LineItem.new(price: 20, quantity: 5, description: "Pants")

      # $30 in Shirts
      i.line_items <<
        LineItem.new(price: 10, quantity: 3, description: "Shirts")

      # $1000 in Hats
      i.line_items << LineItem.new(price: 5, quantity: 200, description: "Hats")

      expect(i.subtotal).to eq(BigDecimal("1130"))
    end

    it "should calculate the correct tax rounded to two decimal places" do
      i = Invoice.new(tax_rate: 0.1)
      i.line_items << LineItem.new(price: 20, quantity: 5, description: "Pants")

      expect(i.tax).to eq(BigDecimal("10"))
    end

    it "shouldn't apply taxes to invoices with subtotal <= 0" do
      i = Invoice.new(tax_rate: 0.1)
      i.line_items << LineItem.new(price: -1, quantity: 100,
        description: "Negative Priced Pants")

      expect(i.tax).to eq(BigDecimal("0"))
    end

    it "should calculate the total for an invoice correctly" do
      i = Invoice.new(tax_rate: 0.1)

      # $100 in Pants
      i.line_items << LineItem.new(price: 20, quantity: 5, description: "Pants")

      # $30 in Shirts
      i.line_items <<
        LineItem.new(price: 10, quantity: 3, description: "Shirts")

      # $1000 in Hats
      i.line_items << LineItem.new(price: 5, quantity: 200, description: "Hats")

      expect(i.total).to eq(BigDecimal("1243"))
    end

    it "is overdue when it's past date and unpaid" do
      i = Invoice.new(due_at: Date.today - 1)
      expect(i.overdue?).to eq(true)
    end

    it "isn't overdue when past due date and paid" do
      i = Invoice.new(due_at: Date.today - 1, paid_at: Date.today)
      expect(i.overdue?).not_to eq(true)
    end

    it "is overdue when due date is a time before the current date" do
      i = Invoice.new(due_at: Time.parse("Jan 1 14:33:20 GMT 2011"))
      expect(i.overdue?).to eq(true)
    end

    it "shouldn't be refunded when not marked refunded" do
      i = Invoice.new
      expect(i.refunded?).not_to eq(true)
    end

    it "should be refunded when marked as refunded" do
      i = Invoice.new(refunded_at: Date.today)
      expect(i.refunded?).to eq(true)
    end

    it "shouldn't be paid when not marked paid" do
      i = Invoice.new
      expect(i.paid?).not_to eq(true)
    end

    it "should be paid when marked as paid" do
      i = Invoice.new(paid_at: Date.today)
      expect(i.paid?).to eq(true)
    end

    it "should be able to iterate over details" do
      i = Invoice.new(invoice_details: [%w(Test Yes), %w(Awesome Absolutely)])
      details = []
      i.each_detail do |key, value|
        details << [key, value]
      end

      expect(details.length).to eq(2)
      expect(details).to include(%w(Test Yes))
      expect(details).to include(%w(Awesome Absolutely))
    end

    it "should be able to iterate through invoice_details as a hash" do
      i = Invoice.new(invoice_details:
        { "Test" => "Yes", "Awesome" => "Absolutely" })
      details = []
      i.each_detail do |key, value|
        details << [key, value]
      end

      expect(details.length).to eq(2)
      expect(details).to include(%w(Test Yes))
      expect(details).to include(%w(Awesome Absolutely))
    end

    describe "rendering" do
      before do
        Dir.mkdir("tmp") unless File.exist?("tmp")
        Config.default.reset
      end

      let(:invoice) { new_invoice(invoice_params) }
      let(:invoice_params) { {} }

      it "should render to a file" do
        File.unlink("tmp/testing.pdf") if File.exist?("tmp/testing.pdf")

        invoice.render_pdf_to_file("tmp/testing.pdf")

        expect(File.exist?("tmp/testing.pdf")).to be true
      end

      context "with some invoice details" do
        let(:invoice_params) do
          {
            invoice_details: {
              "Ordered By:" => "Alan Johnson",
              "Paid By:" => "Dude McDude"
            }
          }
        end

        it "should render an invoice correctly" do
          Payday::Config.default.company_details = <<-EOF
            10 This Way
            Manhattan, NY 10001
            800-111-2222
            awesome@awesomecorp.com
          EOF

          invoice.line_items += [
            LineItem.new(price: 20, quantity: 5, description: "Pants", tax: 1.23),
            LineItem.new(price: 10, quantity: 3, description: "Shirts", tax: 0.1),
            LineItem.new(price: 5, quantity: 200, description: "Hats")
          ] * 30

          expect(invoice.render_pdf).to match_binary_asset "testing.pdf"
        end
      end

      context "paid, with an svg logo" do
        before do
          logo = { filename: "spec/assets/tiger.svg", size: "100x100" }
          Payday::Config.default.invoice_logo = logo
        end

        let(:invoice_params) { { paid_at: Date.civil(2012, 2, 22) } }

        it "should render an invoice correctly" do
          invoice.line_items += [
              LineItem.new(price: 20, quantity: 5, description: "Pants", tax: 1.23),
              LineItem.new(price: 10, quantity: 3, description: "Shirts", tax: 0.1),
              LineItem.new(price: 5, quantity: 200, description: "Hats")
          ] * 3

          expect(invoice.render_pdf).to match_binary_asset "svg.pdf"
        end
      end

      def new_invoice(params = {})
        default_params = {
          tax_rate: 0.1,
          notes: "These are some crazy awesome notes!",
          invoice_number: 12,
          invoice_date: Date.civil(2011, 1, 1),
          due_at: Date.civil(2011, 1, 22),
          bill_to: "Alan Johnson\n101 This Way\nSomewhere, SC 22222",
          ship_to: "Frank Johnson\n101 That Way\nOther, SC 22229"
        }

        Invoice.new(default_params.merge(params))
      end
    end
  end
end
