module Payday
  
  # Configuration for Payday. This is a singleton, so to set the company_name you would call
  # +Payday::Config.default.company_name = "Awesome Corp"+.
  class Config
    attr_accessor :invoice_logo, :company_name, :company_details, :date_format, :currency
    
    # Returns the default configuration instance
    def self.default
      @@default ||= new
    end
    
    private
      def initialize
        self.invoice_logo = File.join(File.dirname(__FILE__), "..", "..", "assets", "default_logo.png")
        self.company_name = "Awesome Corp"
        self.company_details = "awesomecorp@commondream.net"
        self.date_format = "%B %e, %Y"
        self.currency = "USD"
      end
  end
end