class <%= invoice_name.singularize %> < ActiveRecord::Base
  include Payday::Invoiceable
  
  has_many :<%= line_item_name.pluralize.underscore %>
end