module Payday
  
  # The PDF renderer. We use this internally in Payday to render pdfs, but really you should just need to call
  # {{Payday::Invoiceable#render_pdf}} to render pdfs yourself.
  class PdfRenderer
    
    # Renders the given invoice as a pdf on disk
    def self.render_to_file(invoice, path)    
      pdf(invoice).render_file(path)
    end
  
    # Renders the given invoice as a pdf, returning a string
    def self.render(invoice)
      pdf(invoice).render
    end
  
    private
      def self.pdf(invoice)
        pdf = Prawn::Document.new(:page_size => invoice_or_default(invoice, :page_size))

        # set up some default styling
        pdf.font_size(8)
        
        stamp(invoice, pdf)
        company_banner(invoice, pdf)
        bill_to_ship_to(invoice, pdf)
        invoice_details(invoice, pdf)
        line_items_table(invoice, pdf)
        totals_lines(invoice, pdf)
        notes(invoice, pdf)

        pdf
      end
      
      def self.stamp(invoice, pdf)
        stamp = nil
        if invoice.paid?
          stamp = "PAID"
        elsif invoice.overdue?
          stamp = "OVERDUE"
        end

        if stamp
          pdf.bounding_box([200, pdf.cursor - 50], :width => pdf.bounds.width - 400) do
            pdf.font("Helvetica-Bold") do
              pdf.fill_color "cc0000"
              pdf.text stamp, :align=> :center, :size => 25, :rotate => 15
            end
          end
        end

        pdf.fill_color "000000"
      end
      
      def self.company_banner(invoice, pdf)
        # render the logo
        logo_info = pdf.image(invoice_or_default(invoice, :invoice_logo), :at => pdf.bounds.top_left)
        
        # render the company details
        company_details = invoice_or_default(invoice, :company_details)
        company_details = company_details.lines.inject("") { |combined, line| combined << line.strip + "\n" }
        
        table_data = []
        table_data << [bold_cell(pdf, invoice_or_default(invoice, :company_name).strip, :size => 12)]
        table_data << [company_details]
        table = pdf.make_table(table_data, :cell_style => { :borders => [], :padding => [2, 0] })
        pdf.bounding_box([pdf.bounds.width - table.width, pdf.bounds.top], :width => table.width, :height => table.height) do
          table.draw
        end
        
        pdf.move_cursor_to(pdf.bounds.top - logo_info.scaled_height - 20)
      end
      
      def self.bill_to_ship_to(invoice, pdf)
        bill_to_cell_style = { :borders => [], :padding => [2, 0]}
        bill_to_ship_to_bottom = 0
        
        # render bill to
        pdf.float do
          table = pdf.table([[bold_cell(pdf, "Bill To")], [invoice.bill_to]], :column_widths => [200], :cell_style => bill_to_cell_style)
          bill_to_ship_to_bottom = pdf.cursor
        end

        # render ship to
        if defined?(invoice.ship_to)
          table = pdf.make_table([[bold_cell(pdf, "Ship To")], [invoice.ship_to]], :column_widths => [200],
              :cell_style => bill_to_cell_style)
          
          pdf.bounding_box([pdf.bounds.width - table.width, pdf.cursor], :width => table.width, :height => table.height + 2) do
            table.draw
          end
        end

        # make sure we start at the lower of the bill_to or ship_to details
        bill_to_ship_to_bottom = pdf.cursor if pdf.cursor < bill_to_ship_to_bottom
        pdf.move_cursor_to(bill_to_ship_to_bottom - 20)
      end
      
      def self.invoice_details(invoice, pdf)
        # invoice details
        table_data = []

        # invoice number
        if defined?(invoice.invoice_number) && invoice.invoice_number
          table_data << [bold_cell(pdf, "Invoice #:"), bold_cell(pdf, invoice.invoice_number.to_s, :align => :right)]
        end

        # Due on
        if defined?(invoice.due_at) && invoice.due_at
          if invoice.due_at.is_a?(Date) || invoice.due_at.is_a?(Time)
            due_date = invoice.due_at.strftime(Payday::Config.default.date_format)
          else
            due_date = invoice.due_at.to_s
          end

          table_data << [bold_cell(pdf, "Due Date:"), bold_cell(pdf, due_date, :align => :right)]
        end

        # Paid on
        if defined?(invoice.paid_at) && invoice.paid_at
          if invoice.paid_at.is_a?(Date)
            paid_date = invoice.paid_at.strftime(Payday::Config.default.date_format)
          else
            paid_date = invoice.paid_at.to_s
          end

          table_data << [bold_cell(pdf, "Paid Date:"), bold_cell(pdf, paid_date, :align => :right)]
        end

        if table_data.length > 0
          pdf.table(table_data, :cell_style => { :borders => [], :padding => 1 })
        end
      end
      
      def self.line_items_table(invoice, pdf)
        table_data = []
        table_data << [bold_cell(pdf, "Description", :borders => []), 
            bold_cell(pdf, "Unit Price", :align => :center, :borders => []), 
            bold_cell(pdf, "Quantity", :align => :center, :borders => []), 
            bold_cell(pdf, "Amount", :align => :center, :borders => [])]
        invoice.line_items.each do |line|
          table_data << [line.description, number_to_currency(line.price, invoice), BigDecimal.new(line.quantity.to_s).to_s("F"),
              number_to_currency(line.amount, invoice)]
        end

        pdf.move_cursor_to(pdf.cursor - 20)
        pdf.table(table_data, :width => pdf.bounds.width, :header => true, :cell_style => {:border_width => 0.5, :border_color => "cccccc", :padding => [5, 10]},
            :row_colors => ["dfdfdf", "ffffff"]) do
          # left align the number columns
          columns(1..3).rows(1..row_length - 1).style(:align => :right)

          # set the column widths correctly
          natural = natural_column_widths
          natural[0] = width - natural[1] - natural[2] - natural[3]

          column_widths = natural
        end
      end
      
      def self.totals_lines(invoice, pdf)
        table_data = []
        table_data << [bold_cell(pdf, "Subtotal:"), cell(pdf, number_to_currency(invoice.subtotal, invoice), :align => :right)]
        table_data << [bold_cell(pdf, "Tax:"), cell(pdf, number_to_currency(invoice.tax, invoice), :align => :right)]
        table_data << [bold_cell(pdf, "Total:", :size => 12), 
            cell(pdf, number_to_currency(invoice.total, invoice), :size => 12, :align => :right)]
        table = pdf.make_table(table_data, :cell_style => { :borders => [] })
        pdf.bounding_box([pdf.bounds.width - table.width, pdf.cursor], :width => table.width, :height => table.height + 2) do
          table.draw
        end
      end
      
      def self.notes(invoice, pdf)
        if defined?(invoice.notes) && invoice.notes
          pdf.move_cursor_to(pdf.cursor - 30)
          pdf.font("Helvetica-Bold") do
            pdf.text("Notes")
          end
          pdf.line_width = 0.5
          pdf.stroke_color = "cccccc"
          pdf.stroke_line([0, pdf.cursor - 3, pdf.bounds.width, pdf.cursor - 3])
          pdf.move_cursor_to(pdf.cursor - 10)
          pdf.text(invoice.notes.to_s)
        end
      end
      
      def self.invoice_or_default(invoice, property)
        if invoice.respond_to?(property) && invoice.send(property)
          invoice.send(property)
        else
          Payday::Config.default.send(property)
        end
      end
  
      def self.cell(pdf, text, options = {})
        Prawn::Table::Cell::Text.make(pdf, text, options)
      end
    
      def self.bold_cell(pdf, text, options = {})
        options[:font] = "Helvetica-Bold"
        cell(pdf, text, options)
      end
    
      # from Rails, I think
      def self.number_with_delimiter(number, delimiter=",")
        number.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
      end
    
      # Converts this number to a formatted currency string
      def self.number_to_currency(number, invoice)
        number.to_money(invoice_or_default(invoice, :currency)).format
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
end
