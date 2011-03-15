# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "string_score/version"

Gem::Specification.new do |s|
  s.name        = "string_score"
  s.version     = StringScore::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jim Lindley"]
  s.email       = ["mail@jim.io"]
  s.homepage    = ""
  s.summary     = %q{Score how close a string is to another string.}
  s.description = %q{Port of https://github.com/joshaven/string_score from js to ruby.}

  s.rubyforge_project = "string_score"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]


  s.add_development_dependency "rspec", '~>2.5.0'

end
