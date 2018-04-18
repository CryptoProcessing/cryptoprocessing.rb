require 'rake'

require 'bundler/gem_tasks'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :test => :spec
task :default => :spec

namespace :doc do
  begin
    require 'yard'
    YARD::Rake::YardocTask.new do |task|
      task.files   = %w(README.md LICENSE.txt lib/**/*.rb)
      task.options = %w(--output-dir doc/yard --markup markdown)
    end
  rescue LoadError
  end
end
