require 'rake'
require 'rspec/core/rake_task'

desc 'Generate .fixtures.yml from metadata.json or Puppetfile'
task :fixture do
    require 'puppetfiler/cli'

    Puppetfiler.fixture
end

if defined?(:PuppetlabsSpec)
    task :spec_prep => [:fixture]
end
