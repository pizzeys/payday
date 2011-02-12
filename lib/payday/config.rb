module Payday
  class Config
    def self.invoice_logo=(value)
      @invoice_logo = value
    end
    def self.invoice_logo
      @invoice_logo || File.join(File.dirname(__FILE__), "..", "..", "assets", "default_logo.png")
    end
  end
end