Gem::Specification.new do |s|
  s.name					=	'mkgraph'
  s.version				=	'1.1.0'
  s.date          = Date.today.to_s
  s.summary				= 'Dependancy Graph'
  s.description		= 'Create class dependancy graph. This is only partially complete.'
  s.authors				= 'Cliff'
  s.email					=	'cliff@dev.win.com'
  s.files					=	["lib/mkgraph.rb",
  									"test/test_mkgraph.rb",
                    "test/tt.rb",
                    "lib/mgopts.yml",
                    "README.md"
                    ]
  s.add_dependency('ruby-graphviz', ["~> 1.0", ">= 1.0.9"])
  s.add_dependency('tree', ["~> 0.2", ">= 0.2.1"])
  s.homepage			=	'http://dev.win.com'
  s.license				=	'MIT'
  s.rdoc_options  << '--title' << 'Mkgraph' <<
                  '--main' << 'README' <<
                  '--line-numbers'
end
