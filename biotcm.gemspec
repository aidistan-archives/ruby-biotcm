$:.push File.expand_path("../lib", __FILE__)
require 'rake'
require 'biotcm'

Gem::Specification.new do |s|
  s.name        = "biotcm"
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Written for working in Shao lab (BioTCM)"
  s.description = "Integrating several databases, data structure and algorithms, BioTCM is designed as a base gem to build advanced applications on Bioinformatics."

  s.version     = BioTCM::VERSION
  s.license     = 'MIT'

  s.authors     = ["Aidi Stan", "Ming Bai"]
  s.email       = ["aidistan@live.cn", "nmeter@126.com"]
  s.homepage    = "http://biotcm.github.io/biotcm/"

  s.files         = FileList['lib/**/*', 'test/**/*', 'bm/**/*', '.yardopts', 'rakefile', 'LICENSE', '*.md', ].to_a
  s.require_paths = ['lib']
  s.test_files    = FileList['test/**/*'].to_a
  s.executables  << 'biotcm'

  s.add_development_dependency "yard", ">= 0.8.6"
  s.add_development_dependency "shoulda-context", ">= 1.1.5" # for tests
end
