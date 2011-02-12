module Payday::PdfRenderer
  def render_to_pdf(options = {})
    pdf = Prawn::Document.new
    
    pdf.image Payday::Config.invoice_logo, :at => pdf.bounds.top_left, :fit => [100, 100]
    
    pdf.render_file "tmp/testing.pdf"
  end
end