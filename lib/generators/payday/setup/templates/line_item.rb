class <%= options.line_item_name.singularize %> < ActiveRecord::Base
  include Payday::LineItemable
  
  belongs_to :<%= options.invoice_name.underscore %>
end