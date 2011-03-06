module Payday
  
  # Basically just an invoice. Stick a ton of line items in it, add some details, and then render it out!
  class Invoice
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
    
    # Calculates the subtotal of this invoice by adding up all of the line items
    def subtotal
      line_items.inject(BigDecimal.new("0")) { |result, item| result += item.amount }
    end
    
    def tax_rate=(value)
      @tax_rate = BigDecimal.new(value.to_s)
    end
    
    # Calculates the tax for this invoice.
    def tax
      calculated = subtotal * tax_rate
      return 0 if calculated < 0
      calculated
    end
    
    # Calculates the total for this invoice.
    def total
      subtotal + tax
    end
    
    def overdue?
      defined?(:due_on) && due_on.is_a?(Date) && due_on < Date.today && !paid_on
    end
    
    def paid?
      defined?(:paid_on) && paid_on && true
    end
    
    # Renders this invoice to pdf
    def render_to_pdf
      PdfRenderer.render(self)
    end
  end
end