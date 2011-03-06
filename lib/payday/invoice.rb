module Payday
  
  # Basically just an invoice. Stick a ton of line items in it, add some details, and then render it out!
  class Invoice
    include Payday::Invoiceable
    
    attr_accessor :invoice_number, :bill_to, :ship_to, :notes, :line_items, :tax_rate, :tax_description, :due_on, :paid_on
    
    def initialize(options =  {})
      self.invoice_number = options[:invoice_number] || nil
      self.bill_to = options[:bill_to] || nil
      self.ship_to = options[:ship_to] || nil
      self.notes = options[:notes] || nil
      self.line_items = options[:line_items] || []
      self.tax_rate = options[:tax_rate] || nil
      self.tax_description = options[:tax_description] || nil
      self.due_on = options[:due_on] || nil
      self.paid_on = options[:paid_on] || nil
    end
    
    # The tax rate that we're applying, as a BigDecimal    
    def tax_rate=(value)
      @tax_rate = BigDecimal.new(value.to_s)
    end
    
  end
end