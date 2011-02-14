TODO
===

* Apply different tax rates to different line items
* Generate and make sure docs are good
* Move a lot of code into modules that can be included so that classes can be implemented using ActiveRecord or anything
  else.
* Document how to use with ActiveRecord
* Add support for shipping either pre or post tax
* Add block syntax for initializing invoices, just to make things a tiny bit prettier
* Add ability to set pdf document size to something other than 8.5 x 11
* Check and if given invoice object includes company_name and company_details, use them in the invoice
* Ignore company name if it's not present
* Handle displaying an invoice number
* Add invoice_details has for stuff under the invoice number
* Add page numbers
* Get rid of weird line between table cells when removing borders