class <%= options.invoice_name.singularize %> < ActiveRecord::Base
  include Payday::Invoiceable
  
  has_many :<%= options.line_item_name.pluralize.underscore %>
end