$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'biotcm'
require 'bundler/setup'

# test
require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
  # t.verbose = true
end
task default: :test

# cop
namespace :cop do
  task :default do
    system('bundle exec rubocop')
  end
  task :simple do
    system('bundle exec rubocop --format s')
  end
  task :files do
    system('bundle exec rubocop --format files')
  end
  task :html do
    system('bundle exec rubocop --format html -o rubocop.html')
    system('firefox rubocop.html')
  end
end
desc 'Run RuboCop to check styles'
task cop: 'cop:default'

# doc
namespace :doc do
  task :default do
    system('bundle exec yard')
  end
  task :server do
    system('bundle exec yard server -r')
  end
end
desc 'Open YARD doc server'
task doc: 'doc:server'

# clean
desc 'Clean the directory'
task :clean do
  FileList['.yardoc', 'doc', '*.gem'].each do |f|
    FileUtils.rm_r(f) if File.exist?(f) || Dir.exist?(f)
  end
end

# clear
desc 'Clear log files and temporary files in BioTCM.wd'
task :clear do
  %w(log tmp).map { |d| BioTCM.path_to(d) }.each do |d|
    FileUtils.rm_r(d) if Dir.exist?(d)
  end
end

# clear all
desc 'Clear all files in BioTCM.wd'
task clear_all: :clear do
  %w(data).map { |d| BioTCM.path_to(d) }.each do |d|
    FileUtils.rm_r(d) if Dir.exist?(d)
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
      when :major then major = major.to_i + 1
      when :minor then minor = minor.to_i + 1
      when :patch then patch = patch.to_i + 1
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
