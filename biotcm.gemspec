require_relative 'lib/biotcm/version'
require 'rake'

Gem::Specification.new do |s|
  s.name        = 'biotcm'
  s.version     = BioTCM::VERSION
  s.summary     = 'A base gem to build advanced bioinformatics applications.'
  s.description = 'BioTCM is designed as a base gem to build advanced bioinformatics applications.'
  s.license     = 'MIT'

  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.1.5'

  s.authors     = ['Aidi Stan', 'Ming Bai']
  s.email       = ['aidistan@live.cn', 'nmeter@126.com']
  s.homepage    = 'https://github.com/biotcm/biotcm'

  s.files         = FileList['lib/**/*', 'test/**/*', 'LICENSE', '*.md'].to_a
  s.require_paths = ['lib']
  s.test_files    = FileList['test/**/*'].to_a

  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'yard', '~> 0.8'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'minitest-reporters', '~> 1.0'
end
