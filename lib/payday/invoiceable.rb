# Include {Payday::Invoiceable} in your Invoice class to make it Payday compatible. Payday
# expects that a +line_items+ method containing an Enumerable of {Payday::LineItemable} compatible
# elements exists.
#
# Although not required, if a +tax_rate+ method exists, {Payday::Invoiceable} will use it to calculate tax
# when generating an invoice. We include a simple tax method that calculates tax, but it's probably wiser
# to override this in your class (our calculated tax won't be stored to a database by default, for example).
#
# If the +due_on+ and +paid_on+ methods are available, {Payday::Invoiceable} will use them to show due dates and
# paid dates, as well as stamps showing if the invoice is paid or due.
module Payday::Invoiceable
  
  # Calculates the subtotal of this invoice by adding up all of the line items
  def subtotal
    line_items.inject(BigDecimal.new("0")) { |result, item| result += item.amount }
  end
  
  # The tax for this invoice, as a BigDecimal
  def tax
    if defined?(tax_rate)
      calculated = subtotal * tax_rate
      return 0 if calculated < 0
      calculated
    else
      0
    end
  end
  
  # Calculates the total for this invoice.
  def total
    subtotal + tax
  end
  
  def overdue?
    defined?(:due_on) && due_on.is_a?(Date) && due_on < Date.today && !paid_on
  end
  
  def paid?
    defined?(:paid_on) && !!paid_on
  end
  
  # Renders this invoice to pdf
  def render_to_pdf
    Payday::PdfRenderer.render(self)
  end
end