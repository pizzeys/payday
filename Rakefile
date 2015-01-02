require "bundler"

require "rake"
require "rake/testtask"

task default: :test

Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.test_files = FileList["test/**/*_test.rb"]
end
