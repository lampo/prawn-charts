require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.test_files = FileList['spec/*_spec.rb']
end

desc "Run Specs"
task default: :test

