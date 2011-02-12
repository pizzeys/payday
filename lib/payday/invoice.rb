module Payday
  
  # Basically just an invoice. Stick a ton of line items in it, add some details, and then render it out!
  class Invoice
    include Payday::PdfRenderer
    
    attr_accessor :company_details, :bill_to, :ship_to, :notes, :line_items, :tax_rate, :tax_description
    
    def initialize(options =  {})
      self.company_details = options[:company_details] || nil
      self.bill_to = options[:bill_to] || nil
      self.ship_to = options[:ship_to] || nil
      self.notes = options[:notes] || nil
      self.line_items = options[:line_items] || []
      self.tax_rate = options[:tax_rate] || []
      self.tax_description = options[:tax_description] || []
    end
    
    # Calculates the subtotal of this invoice by adding up all of the line items
    def subtotal
      line_items.inject(BigDecimal.new("0")) { |result, item| result += item.total }
    end
    
    def tax_rate=(value)
      @tax_rate = BigDecimal.new(value.to_s)
    end
    
    # Calculates the tax for this invoice.
    def tax
      subtotal * tax_rate
    end
    
    # Calculates the total for this invoice.
    def total
      subtotal + tax
    end
    
    # Renders this invoice to html. The html is fairly set in stone but pretty easy to style however you'd like.
    # Of course, if it doesn't fit your needs it shouldn't be too hard to just render an invoice differently.
    def render_to_html
    end
  end
end