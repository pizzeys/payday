module Payday
  class Config
    attr_accessor :invoice_logo, :company_name, :company_details
    
    def initialize
      self.invoice_logo = File.join(File.dirname(__FILE__), "..", "..", "assets", "default_logo.png")
      self.company_name = "Awesome Corp"
      self.company_details = "awesomecorp@commondream.net"
    end
    
    def self.default
      @@default ||= new
    end
  end
end