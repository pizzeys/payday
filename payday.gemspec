# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "payday/version"

Gem::Specification.new do |s|
  s.name        = "payday"
  s.version     = Payday::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alan Johnson"]
  s.email       = ["alan@commondream.net"]
  s.homepage    = "https://github.com/commondream/payday"
  s.summary     = "A simple library for rendering invoices."
  s.description = <<-EOF
    Payday is a library for rendering invoices. At present it supports rendering
    invoices to pdfs, but we're planning on adding support for other formats in
    the near future.
  EOF

  s.add_dependency("prawn", "~> 2.2.0")
  s.add_dependency("prawn-svg", "~> 0.27.1")
  s.add_dependency("prawn-table", "~> 0.2.2")
  s.add_dependency("money", ">= 6.9.0")
  s.add_dependency("i18n", ">= 0.8")

  s.add_development_dependency("rspec", "~> 3.5.0")

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables =
    `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
