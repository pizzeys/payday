module Payday::PdfRenderer
  def render_to_pdf(options = {})
    pdf = Prawn::Document.new
    
    pdf.image(defined?(self.invoice_logo) && self.invoice_logo ? self.invoice_logo : Payday::Config.default.invoice_logo, 
        :at => pdf.bounds.top_left, :fit => [100, 100])
    
    pdf.render_file "tmp/testing.pdf"
  end
end