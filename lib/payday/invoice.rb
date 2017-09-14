module Payday
  # Basically just an invoice. Stick a ton of line items in it, add some details, and then render it out!
  class Invoice
    include Payday::Invoiceable

    attr_accessor :invoice_number, :bill_to, :ship_to, :notes, :line_items, :shipping_rate, :shipping_description,
      :tax_rate, :tax_description, :tax2_rate, :tax2_description, :due_at, :paid_at, :refunded_at, :currency, :invoice_details, :invoice_date

    def initialize(options =  {})
      self.invoice_number = options[:invoice_number] || nil
      self.bill_to = options[:bill_to] || nil
      self.ship_to = options[:ship_to] || nil
      self.notes = options[:notes] || nil
      self.line_items = options[:line_items] || []
      self.shipping_rate = options[:shipping_rate] || "0.00"
      self.shipping_description = options[:shipping_description] || nil
      self.tax_rate = options[:tax_rate] || "0.00"
      self.tax_description = options[:tax_description] || nil
      self.tax2_rate = options[:tax2_rate] || "0.00"
      self.tax2_description = options[:tax2_description] || nil
      self.due_at = options[:due_at] || nil
      self.paid_at = options[:paid_at] || nil
      self.refunded_at = options[:refunded_at] || nil
      self.currency = options[:currency] || nil
      self.invoice_details = options[:invoice_details] || []
      self.invoice_date = options[:invoice_date] || nil
    end

    # The tax rate that we're applying, as a BigDecimal
    def tax_rate=(value)
      @tax_rate = BigDecimal.new(value.to_s)
    end

    def tax2_rate=(value)
      @tax2_rate = BigDecimal.new(value.to_s)
    end

    # Shipping rate
    def shipping_rate=(value)
      @shipping_rate = BigDecimal.new(value.to_s)
    end
  end
end
