# Include this module into your line item implementation to make sure that Payday stays happy
# with it, or just make sure that your line item implements the amount method.
module Payday::LineItemable
  # Returns the total amount for this {LineItemable}, or +price * quantity+
  def amount_no_tax
    price * quantity
  end

  def item_tax
    tax * quantity
  end

  def amount
    amount_no_tax + item_tax
  end
end
