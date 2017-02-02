require 'thor'
require 'puppetfiler/puppetfile'
require 'puppetfiler/version'

module Puppetfiler
    class CLI < Thor
        desc 'check [puppetfile]', 'Check forge for newer versions of used forge modules'
        def check(puppetfile)
            pf = Puppetfiler::Puppetfile(puppetfile)
            format = "% -#{pf.maxlen}s\t%s\t%s"

            puts sprintf(format, 'module', 'installed', 'newest')

            pf.updates do |name, hash|
                puts sprintf(format, name, hash[:current], hash[:newest])
            end
        end

        desc 'fixture [puppetfile]', 'Create puppetlabs_spec_helper compatible .fixtures.yml from puppetfile'
        def fixture(puppetfile)
            puts Puppetfiler::Puppetfile(puppetfile).fixture
        end

        desc 'version', 'Output version'
        def version
            puts "puppetfiler v#{Puppetfiler::VERSION}"
        end
    end
end
