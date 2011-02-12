module Payday::PdfRenderer
  def render_to_pdf(options => {})
    pdf = Prawn::Document.new
    
    pdf.text "Hello World!"
    
    pdf.render_file 
  end
end