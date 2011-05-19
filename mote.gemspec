require "./lib/mote"

Gem::Specification.new do |s|
  s.name              = "mote"
  s.version           = Mote::VERSION
  s.version           = "0.0.1.rc3"
  s.summary           = "Minimum Operational Template."
  s.description       = "Mote is the little brother of ERB. It only provides a subset of ERB's features, but praises itself of being simple--both internally and externally--and super fast."
  s.authors           = ["Michel Martens"]
  s.email             = ["michel@soveran.com"]
  s.homepage          = "http://github.com/soveran/mote"
  s.files = Dir[
    "LICENSE",
    "README.markdown",
    "Rakefile",
    "lib/**/*.rb",
    "*.gemspec",
    "test/**/*.rb"
  ]
  s.add_development_dependency "cutest", "~> 0.1"
end
