require 'rails/generators'
require 'rails/generators/migration'

# rails g payday:setup <invoice_name> <line_item_name>
# Generates models for invoicing with Payday includes prepped
# Params:

# OPTIONS:
# --skip-migration - Does not create the migration file for invoicing
module Payday
  class SetupGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    
    source_root File.expand_path('../templates', __FILE__)
    
    argument :invoice_name, :type => :string, :default => "Invoice"
    argument :line_item_name, :type => :string, :default => "LineItem"
    class_option :skip_migration, :desc => "Does not create the migration file for tables", :type => :boolean
    
    def generate_invoice_model
      template "invoice.rb", "app/models/#{invoice_name.underscore}.rb"
    end
    
    def generate_line_item_model
      template "line_item.rb", "app/models/#{line_item_name.underscore}.rb"
    end
    
    def generate_migration
      unless options.skip_migration?
        migration_template 'migration.rb', "db/migrate/create_payday_tables.rb"
      end
    end
    
    private
    
    def self.next_migration_number(dirname)
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end
  end
end