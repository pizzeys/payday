class Payday::PdfRenderer
  def self.render(invoice)
    pdf = Prawn::Document.new
    
    logo_info = pdf.image(
        defined?(invoice.invoice_logo) && invoice.invoice_logo ? invoice.invoice_logo : Payday::Config.default.invoice_logo, 
        :at => pdf.bounds.top_left, :fit => [100, 100])

    pdf.bounding_box([logo_info.scaled_width + 5, pdf.bounds.top], :width => pdf.bounds.width - logo_info.scaled_width - 5) do
      pdf.text(defined?(invoice.company_name) && invoice.company_name ? invoice.company_name : Payday::Config.default.company_name)
      pdf.text(
        defined?(invoice.company_details) && invoice.company_details ? invoice.company_details : Payday::Config.default.company_details)
    end
    
    pdf.move_cursor_to(pdf.bounds.top - logo_info.scaled_height - 20)
    
    pdf.float do
      pdf.table([[bold_cell(pdf, "Bill To")], ["Someone"]], :column_widths => [200])
    end
    
    table = pdf.make_table([[bold_cell(pdf, "Ship To")], ["Someone Else"]], :column_widths => [200])
    pdf.bounding_box([pdf.bounds.width - table.width, pdf.cursor], :width => table.width, :height => table.height) do
      table.draw
    end
    
    table_data = []
    table_data << [bold_cell(pdf, "Description"), bold_cell(pdf, "Price"), bold_cell(pdf, "Quantity"), 
        bold_cell(pdf, "Total")]
    invoice.line_items.each do |line|
      table_data << [line.description, number_to_currency(line.price), line.quantity.to_s("F"),
          number_to_currency(line.total)]
    end
    table_data << [nil, nil, bold_cell(pdf, "Subtotal:"), number_to_currency(invoice.subtotal)]
    table_data << [nil, nil, bold_cell(pdf, "Tax:"), number_to_currency(invoice.tax)]
    table_data << [nil, nil, bold_cell(pdf, "Total:"), number_to_currency(invoice.total)]
    
    pdf.move_cursor_to(pdf.cursor - 30)
    pdf.table(table_data, :width => pdf.bounds.width)
    
    pdf.move_cursor_to(pdf.cursor - 10)
    pdf.text(invoice.notes.to_s)
    
    pdf.render_file("tmp/testing.pdf")
  end
  
  private
    def self.bold_cell(pdf, text)
      Prawn::Table::Cell::Text.make(pdf, text, :font => "Helvetica-Bold")
    end
    
    def self.number_to_currency(number)
      sprintf("$%.02f", number)
    end
end