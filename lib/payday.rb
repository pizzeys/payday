# Not much to see here
require "date"
require "time"
require "bigdecimal"
require "prawn"
require "prawn-svg"
require "prawn/table"
require "money"

require_relative "payday/version"
require_relative "payday/config"
require_relative "payday/i18n"
require_relative "payday/line_itemable"
require_relative "payday/line_item"
require_relative "payday/pdf_renderer"
require_relative "payday/invoiceable"
require_relative "payday/invoice"

Prawn::Font::AFM.hide_m17n_warning = true

Money.locale_backend = :i18n