Payday!
===
Payday is a library for rendering invoices. At present it supports rendering invoices to pdfs, but we're planning on adding support for other formats in the near future.

Using Payday
===
It's pretty easy to use Payday with the built in objects. We include the Invoice and LineItem classes, and with them you can get started pretty quickly.

Example:

    invoice = Payday::Invoice.new(:invoice_number => 12)
    i.line_items << LineItem.new(:price => 20, :quantity => 5, :description => "Pants")
    i.line_items << LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")
    i.line_items << LineItem.new(:price => 5, :quantity => 200, :description => "Hats")
    i.render_pdf_to_file("/path/to_file.pdf")

Customizing Your Logo and Company Name
===
Check out Payday::Config to customize your company's name, details, and logo.

Example:

    Payday::Config.default.invoice_log = "/path/to/company/logo.png"
    Payday::Config.default.company_name = "Awesome Corp"
    Payday::Config.default.company_details = "10 This Way\nManhattan, NY 10001\n800-111-2222\nawesome@awesomecorp.com"

Using Payday with ActiveRecord Objects (or any other objects, for that matter)
===

TODO

Rendering Payday PDFs To The Web
===
Payday's Invoiceable module includes methods for rendering pdfs to disk and for rendering them to a string. In a Rails controller, you can use the
render to string method to render a pdf directly to the browser like this:

In environment.rb:
  
    Mime::Type.register 'application/pdf', :pdf
    
In your controller:

    respond_to do |format|
      format.html
      format.pdf do
        send_data invoice.render_pdf, :filename => "Invoice #12.pdf", :type => "application/pdf", :disposition => :inline
      end
    end

Contributing
===
Payday is pretty young, so there's still a good bit of work to be done. Feel free to fork the project, make some changes, and send a pull request. If you're unsure about what to work on, send me a message on GitHub. I'd love the help!

To Do
===
Here's what we're planning on working on with Payday in the near future:

* Package as gem
* Document how to use with ActiveRecord
* Release 1.0!

* Add support for currencies other than USD
* Add support for Money gem or BigDecimal or general numerics (right now we support BigDecimal and general numerics)
* Add support for blank line items
* Add support for indented line items
* Apply different tax rates to different line items
* Add support for shipping either pre or post tax
* Add ability to set pdf document size to something other than 8.5 x 11
* Add invoice_details has for stuff under the invoice number
* Add ability to show skus or product ids on each line item

* Add page numbers
* Ability to render invoice to html for web viewing