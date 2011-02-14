class Payday::PdfRenderer
  def self.render(invoice)
    pdf = Prawn::Document.new
    
    # set up some default styling
    pdf.font_size(8)
    
    # render the logo
    logo_info = pdf.image(
        defined?(invoice.invoice_logo) && invoice.invoice_logo ? invoice.invoice_logo : Payday::Config.default.invoice_logo, 
        :at => pdf.bounds.top_left, :fit => [100, 100])

    # render the company details
    table_data = []
    table_data << [bold_cell(pdf, defined?(invoice.company_name) && invoice.company_name ? invoice.company_name : Payday::Config.default.company_name)]
    table_data << [defined?(invoice.company_details) && invoice.company_details ? invoice.company_details : Payday::Config.default.company_details]
    table = pdf.make_table(table_data, :cell_style => { :borders => [], :padding => [2, 0] })
    pdf.bounding_box([pdf.bounds.width - table.width, pdf.bounds.top], :width => table.width, :height => table.height) do
      table.draw
    end
    
    bill_to_cell_style = { :borders => [], :padding => [2, 0]}
    
    # render bill to
    pdf.move_cursor_to(pdf.bounds.top - logo_info.scaled_height - 20)
    pdf.float do
      pdf.table([[bold_cell(pdf, "Bill To")], ["Someone"]], :column_widths => [200], :cell_style => bill_to_cell_style)
    end
    
    # render ship to
    table = pdf.make_table([[bold_cell(pdf, "Ship To")], ["Someone Else"]], :column_widths => [200],
        :cell_style => bill_to_cell_style)
    pdf.bounding_box([pdf.bounds.width - table.width, pdf.cursor], :width => table.width, :height => table.height + 2) do
      table.draw
    end
    
    # render the invoice details
    pdf.move_cursor_to(pdf.cursor - 20)
    table_data = []
    if invoice.invoice_number
      table_data << [bold_cell(pdf, "Invoice #"), bold_cell(pdf, invoice.invoice_number.to_s)]
    end
    
    if table_data.length > 0
      pdf.table(table_data, :cell_style => { :borders => [:bottom], :border_color => "cccccc"}) do
        rows(row_length - 1).style(:borders => [])
      end
    end
    
    # render the line items
    table_data = []
    table_data << [bold_cell(pdf, "Description", :borders => []), 
        bold_cell(pdf, "Unit Price", :align => :center, :borders => []), 
        bold_cell(pdf, "Quantity", :align => :center, :borders => []), 
        bold_cell(pdf, "Amount", :align => :center, :borders => [])]
    invoice.line_items.each do |line|
      table_data << [line.description, number_to_currency(line.price), line.quantity.to_s("F"),
          number_to_currency(line.amount)]
    end
    table_data << [nil, nil, bold_cell(pdf, "Subtotal:"), number_to_currency(invoice.subtotal)]
    table_data << [nil, nil, bold_cell(pdf, "Tax:"), number_to_currency(invoice.tax)]
    table_data << [nil, nil, bold_cell(pdf, "Total:"), number_to_currency(invoice.total)]
    
    pdf.move_cursor_to(pdf.cursor - 20)
    pdf.table(table_data, :width => pdf.bounds.width, :header => true, :cell_style => {:border_width => 0.5, :border_color => "cccccc", :padding => [5, 10]},
        :row_colors => ["dfdfdf", "ffffff"]) do
      # left align the number columns
      columns(3).rows(1..row_length - 1).style(:align => :right)
      columns(2).rows(1..row_length - 4).style(:align => :right)
      columns(1).rows(1..row_length - 4).style(:align => :right)
      
      # set the column widths correctly
      natural = natural_column_widths
      natural[0] = width - natural[1] - natural[2] - natural[3]
      
      column_widths = natural
    end
    
    # render the notes
    pdf.move_cursor_to(pdf.cursor - 30)
    pdf.font("Helvetica-Bold") do
      pdf.text("Notes")
    end
    pdf.line_width = 0.5
    pdf.stroke_color = "cccccc"
    pdf.stroke_line([0, pdf.cursor - 3, pdf.bounds.width, pdf.cursor - 3])
    pdf.move_cursor_to(pdf.cursor - 10)
    pdf.text(invoice.notes.to_s)
    
    # just dump it all out to a file for now
    pdf.render_file("tmp/testing.pdf")
  end
  
  private
    def self.bold_cell(pdf, text, options = {})
      options[:font] = "Helvetica-Bold"
      
      Prawn::Table::Cell::Text.make(pdf, text, options)
    end
    
    def self.number_to_currency(number)
      sprintf("$%.02f", number)
    end
    
    def self.max_cell_width(cell_proxy)
      max = 0
      cell_proxy.each do |cell|
        if cell.natural_content_width > max
          max = cell.natural_content_width
        end
      end
      
      max
    end
end