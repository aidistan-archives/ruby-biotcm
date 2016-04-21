require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rainbow'
CLOBBER.include '.yardoc', 'doc'

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.description = 'Run tests (as :default)'
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
  # t.verbose = true
end
task default: :test

desc 'Serve YARD documents'
task :doc do
  system('bundle exec yard server --port 4000 --reload')
end

desc 'Check before release'
namespace :release do
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
