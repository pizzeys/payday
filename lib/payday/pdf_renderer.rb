module Payday::PdfRenderer
  def render_to_pdf(options = {})
    pdf = Prawn::Document.new
    
    logo_info = pdf.image(
        defined?(self.invoice_logo) && self.invoice_logo ? self.invoice_logo : Payday::Config.default.invoice_logo, 
        :at => pdf.bounds.top_left, :fit => [100, 100])

    pdf.bounding_box([logo_info.scaled_width + 5, pdf.bounds.top], :width => pdf.bounds.width - logo_info.scaled_width - 5) do
      pdf.text(defined?(self.company_name) && self.company_name ? self.company_name : Payday::Config.default.company_name)
      pdf.text(
        defined?(self.company_details) && self.company_details ? self.company_details : Payday::Config.default.company_details)
    end
    
    pdf.move_cursor_to(pdf.bounds.top - logo_info.scaled_height - 5)
    
    pdf.float do
      pdf.table([["Bill To"], ["Someone"]], :column_widths => [200])
    end
    
    table = pdf.make_table([["Ship To"], ["Someone Else"]], :column_widths => [200])
    pdf.bounding_box([pdf.bounds.width - table.width, pdf.cursor], :width => table.width, :height => table.height) do
      table.draw
    end
    
    table_data = []
    table_data << ["Description", "Price", "Quantity", "Total"]
    line_items.each do |line|
      table_data << [line.description, line.price.to_s, line.quantity.to_s, line.total.to_s]
    end
    table_data << [nil, nil, "Subtotal:", subtotal.to_s('F')]
    table_data << [nil, nil, "Tax", tax.to_s('F')]
    table_data << [nil, nil, "Total", total.to_s('F')]
    
    pdf.move_cursor_to(pdf.cursor - 5)
    pdf.table(table_data, :width => pdf.bounds.width)
    
    pdf.move_cursor_to(pdf.cursor - 10)
    pdf.text(notes.to_s)
    
    pdf.render_file("tmp/testing.pdf")
  end
end