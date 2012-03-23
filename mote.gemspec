require "./lib/mote"

Gem::Specification.new do |s|
  s.name              = "mote"
  s.version           = Mote::VERSION
  s.summary           = "Minimum Operational Template."
  s.description       = "Mote is a very simple and fast template engine."
  s.authors           = ["Michel Martens"]
  s.email             = ["michel@soveran.com"]
  s.homepage          = "http://github.com/soveran/mote"
  s.files = Dir[
    "LICENSE",
    "AUTHORS",
    "README.md",
    "Rakefile",
    "lib/**/*.rb",
    "*.gemspec",
    "test/**/*.rb"
  ]
  s.executables.push("mote")
  s.add_development_dependency "cutest"
end
