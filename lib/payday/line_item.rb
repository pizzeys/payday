module Payday
  # Represents a line item in an invoice.
  #
  # quantity and price are written to be pretty picky, primarily because if we're not picky about what values are set to
  # them your invoice math could get pretty messed up. It's recommended that both values be set to BigDecimal values.
  # Otherwise, we'll do our best to convert the set values to a BigDecimal.
  class LineItem
    attr_accessor :description, :quantity, :price
    
    def initialize
      @quantity = BigDecimal.new("1")
      @price = BigDecimal.new("0.00")
    end
    
    def quantity=(value)
      @quantity = BigDecimal.new(value.to_s)
    rescue => e
      raise Payday::Error, "Quantity couldn't be converted to a BigDecimal: #{e.message}"
    end
    
    def price=(value)
      @price = BigDecimal.new(value.to_s)
    rescue => e
      raise Payday::Error, "Price couldn't be converted to a BigDecimal: #{e.message}"
    end
  end
end