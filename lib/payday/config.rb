module Payday
  class Config
    attr_accessor :invoice_logo, :company_name, :company_details, :date_format, :currency
    
    def initialize
      self.invoice_logo = File.join(File.dirname(__FILE__), "..", "..", "assets", "default_logo.png")
      self.company_name = "Awesome Corp"
      self.company_details = "awesomecorp@commondream.net"
      self.date_format = "%B %e, %Y"
    end
    
    def self.default
      @@default ||= new
    end
  end
end