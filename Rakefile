require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default do
    %i{spec}.each do |task|
        Rake::Task[task].invoke
    end
end
