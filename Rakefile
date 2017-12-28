require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rainbow'
require 'rake/testtask'
CLOBBER.include '.yardoc', 'doc'

task default: 'test:quick'

namespace :test do
  Rake::TestTask.new(:quick) do |t|
    t.description = 'Run quick test suite (as :default)'
    t.libs << 'test'
    t.test_files = FileList['test/**/test_*.rb'] - FileList['test/biotcm/apps/test_*.rb']
  end

  Rake::TestTask.new(:full) do |t|
    t.description = 'Run full test suite'
    t.libs << 'test'
    t.test_files = FileList['test/**/test_*.rb']
  end
end

desc 'Serve YARD documents'
task :doc do
  system('bundle exec yard server --reload')
end

namespace :release do
  desc 'Check and commit then invoke :release task'
  task with_check: %w[release:check release:commit release]

  # Check before commit
  task :check do
    changed_files = `git diff-files`.split("\n").map { |l| l.split("\t").last }
    concerned_files = %w[lib/biotcm/version.rb HISTORY.md]

    (concerned_files - changed_files).each do |file|
      puts "#{Rainbow(file).bright} has not been updated"
    end

    (changed_files - concerned_files).each do |file|
      puts "#{Rainbow(file).bright} should not be updated"
    end

    exit unless (changed_files | concerned_files) == changed_files
  end

  # Commit before release
  task :commit do
    require_relative 'lib/biotcm/version.rb'
    system("git commit -am 'Bump to v#{BioTCM::VERSION}'")
  end
end
