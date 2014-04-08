module Payday

  # Configuration for Payday. This is a singleton, so to set the company_name you would call
  # Payday::Config.default.company_name = "Awesome Corp".
  class Config
    attr_accessor :invoice_logo, :company_name, :company_details, :date_format, :currency

    # Sets the page size to use. See the
    # {http://prawn.majesticseacreature.com/docs/0.10.2/Prawn/Document/PageGeometry.html Prawn documentation} for valid
    # page_size values.
    attr_accessor :page_size

    # Returns the default configuration instance
    def self.default
      @@default ||= new
    end

    # Internal: Resets a config object back to its default settings.
    #
    # Primarily intended for use in our tests.
    def reset
        # TODO: Move into specs and make minimal configuration required (company name / details)
        self.invoice_logo = File.join(File.dirname(__FILE__), "..", "..", "spec", "assets", "default_logo.png")
        self.company_name = "Awesome Corp"
        self.company_details = "awesomecorp@commondream.net"
        self.date_format = "%B %e, %Y"
        self.currency = "USD"
        self.page_size = "LETTER"
    end

    # Internal: Contruct a new config object.
    def initialize
      reset
    end
  end
end
