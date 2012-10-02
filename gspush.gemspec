# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gspush/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["HORII Keima"]
  gem.email         = ["holysugar@gmail.com"]
  gem.description   = %q{Push command to Google Spreadsheet}
  gem.summary       = %q{Phsh command to Google Spreadsheet}
  gem.homepage      = "https://github.com/holysugar/gspush"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "gspush"
  gem.require_paths = ["lib"]
  gem.version       = Gspush::VERSION

  gem.add_dependency "google_drive"

  ["rspec", "fakefs"].each do |g|
    gem.add_development_dependency g
  end
end
