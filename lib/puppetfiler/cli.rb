require 'thor'
require 'yaml'
require 'puppetfiler/puppetfile'
require 'puppetfiler/version'

module SemanticPuppet
    class Version < Numeric
        def length
            to_s.length
        end
    end
end

module Puppetfiler
    class CLI < Thor
        class_option :puppetfile, {
            :default => nil,
            :desc    => 'Puppetfile to act on',
            :aliases => ['p'],
        }

        class_option :metadata, {
            :default => nil,
            :desc    => 'metadata.json to act on',
            :aliases => ['m'],
        }

        desc 'check', 'Check forge for newer versions of used forge modules'
        def check()
            target = target(options)

            case target[:type]
            when :puppetfile
                t = Puppetfiler::Puppetfile.new(target[:result])
            when :metadata
                # TODO see below
                fail 'Checking metadata.json for version range updates is not implemented yet'
            else fail "Unkown type: #{target[:type]}"
            end

            format = "% -#{t.maxlen_name}s  % -#{t.maxlen_ver}s  %s"

            puts sprintf(format, 'module', 'current', 'newest')

            # TODO the updates should be collected asynchronously to
            # speed up the process
            t.updates.each do |name, hash|
                puts sprintf(format, name, hash[:current], hash[:newest])
            end
        end

        desc 'fixture', 'Create puppetlabs_spec_helper compatible .fixtures.yml from puppetfile or metadata.json'
        method_option :stdout, :aliases => '-o'
        def fixture()
            target = target(options)

            case target[:type]
            when :puppetfile
                f = Puppetfiler::Puppetfile.new(target[:result])
            when :metadata
                f = Puppetfiler::Metadata.new(File.new(target[:result]))
            else fail "Unkown type: #{target[:type]}"
            end

            f = f.fixture.to_yaml

            if options[:stdout]
                puts f
            else
                File.write('.fixtures.yml', f)
            end
        end

        desc 'version', 'Output version'
        def version
            puts "puppetfiler v#{Puppetfiler::VERSION}"
        end

        private
        def target(opts)
            {
                :puppetfile => 'Puppetfile',
                :metadata   => 'metadata.json',
            }.each do |sym, str|
                if opts[sym]
                    return { :result => opts[sym], :type => sym }
                elsif File.exists?(str)
                    return { :result => str, :type => sym }
                end
            end

            fail 'No Puppetfile or metadata.json found, aborting'
        end
    end
end
