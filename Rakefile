$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'biotcm'
require 'bundler/setup'

# test
require 'rake/testtask'
Rake::TestTask.new do |t|
  t.description = 'Run tests (as :default)'
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
  # t.verbose = true
end
task default: :test

# cop
namespace :cop do
  desc 'Run RuboCop and output in simple format'
  task :simple do
    system('bundle exec rubocop --format s')
  end
  desc 'Run RuboCop and output in files format'
  task :files do
    system('bundle exec rubocop --format files')
  end
  desc 'Run RuboCop and output in html format'
  task :html do
    system('bundle exec rubocop --format html -o doc/rubocop.html')
    system('firefox doc/rubocop.html')
  end
end

# doc
namespace :doc do
  desc 'Build YARD docs'
  task :build do
    system('bundle exec yard')
  end
  desc 'Open YARD server (as :doc)'
  task :serve do
    system('bundle exec yard server --port 4000 --reload')
  end
end
task doc: 'doc:serve'

# clean
desc 'Clean the directory'
task :clean do
  FileList['.yardoc', 'doc', '*.gem'].each do |f|
    FileUtils.rm_r(f) if File.exist?(f) || Dir.exist?(f)
  end
end

# bump
namespace :bump do
  desc 'Bump major version code'
  task :major do
    bump_version :major
  end
  desc 'Bump minor version code'
  task :minor do
    bump_version :minor
  end
  desc 'Bump patch version code'
  task :patch do
    bump_version :patch
  end
end
def bump_version(which)
  lines = File.read('lib/biotcm/version.rb').split("\n")
  lines.collect! do |l|
    if /^\s+VERSION/ =~ l
      /'(?<major>\d+)\.(?<minor>\d+).(?<patch>\d+)'/ =~ l
      case which
      when :major
        major = major.to_i + 1
        minor = 0
        patch = 0
      when :minor
        minor = minor.to_i + 1
        patch = 0
      when :patch
        patch = patch.to_i + 1
      end
      l.gsub(/'\d+\.\d+.\d+'/, "'#{major}.#{minor}.#{patch}'")
    else
      l
    end
  end
  File.open('lib/biotcm/version.rb', 'w').puts lines
end

# gem
desc 'Build the gem'
task :gem do
  system("gem build #{File.dirname(__FILE__)}" + '/biotcm.gemspec')
end

# install
desc 'Install the gem'
task install: :gem do
  system("gem install biotcm-#{BioTCM::VERSION}.gem --local --no-document")
end

# uninstall
desc 'Uninstall the gem'
task :uninstall do
  system('gem uninstall biotcm')
end
