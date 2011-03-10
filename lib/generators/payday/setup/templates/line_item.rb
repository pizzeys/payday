class <%= line_item_name.singularize %> < ActiveRecord::Base
  include Payday::LineItemable
  
  belongs_to :<%= invoice_name.underscore %>
end