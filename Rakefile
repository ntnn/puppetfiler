require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new(:spec)

Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = 'features --format pretty'
end

task :default do
    require 'simplecov'
    require 'simplecov-console'

    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Console,
    ]

    SimpleCov.start

    %i{spec features}.each do |task|
        Rake::Task[task].invoke
    end
end
