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
    # t.verbose = true
  end

  Rake::TestTask.new(:full) do |t|
    t.description = 'Run full test suite'
    t.libs << 'test'
    t.test_files = FileList['test/**/test_*.rb']
    # t.verbose = true
  end
end

desc 'Serve YARD documents'
task :doc do
  system('bundle exec yard server --reload')
end

namespace :release do
  desc 'Check before release'
  task :check do
    unchanged_files =
      %w(lib/biotcm/version.rb HISTORY.md Gemfile.lock) -
      `git diff-files`.split("\n").map { |l| l.split("\t").last }

    if unchanged_files.empty?
      puts Rainbow('All files updated').green
    else
      unchanged_files.each do |file|
        puts "#{Rainbow(file).bright} has not been updated"
      end
    end
  end
end
