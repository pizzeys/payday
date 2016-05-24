# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "payday/version"

Gem::Specification.new do |s|
  s.name        = "payday"
  s.version     = Payday::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alan Johnson"]
  s.email       = ["alan@commondream.net"]
  s.homepage    = ""
  s.summary     = %q{git remote add origin git@github.com:commondream/payday.git}
  s.description = %q{Payday is a library for rendering invoices. At present it supports rendering invoices to pdfs, but we're planning on adding support for other formats in the near future.}

  s.add_dependency("prawn", "~> 0.12.0")
  s.add_dependency("money", "~> 3.6.1")
  s.add_dependency("prawn-svg", "~> 0.9.1")
  s.add_dependency("i18n", ">= 0.5.0")

  s.add_development_dependency("minitest")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end