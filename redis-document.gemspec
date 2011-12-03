# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis/document/version"

Gem::Specification.new do |s|
  s.name        = "redis-document"
  s.version     = Redis::Document::VERSION
  s.authors     = ["Jared Grippe"]
  s.email       = ["jared@deadlyicon.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "redis-document"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "ruby-debug"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "autotest"
  s.add_development_dependency "autotest-growl"
  s.add_development_dependency "autotest-fsevent"

  s.add_runtime_dependency "redis"
  s.add_runtime_dependency "redis-namespace"
  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency "activemodel"
  s.add_runtime_dependency "uuid"
end
