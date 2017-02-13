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
        def check
            t = [nil, nil]
            %i{puppetfile metadata}.each do |m|
                if not options[m].nil?
                    t = [m, options[m]]
                end
            end
            updates = Puppetfiler.check(*t)

            if updates.empty?
                return
            end

            maxlen_name = 0
            maxlen_val  = 0
            val_count   = 0

            updates.each do |name, hash|
                maxlen_name = name.length if name.length > maxlen_name
                hash.each do |k, v|
                    val_count += 1
                    maxlen_val = k.length if k.length > maxlen_val
                    maxlen_val = v.length if v.length > maxlen_val
                end
            end

            format = "% -#{maxlen_name}s  " + ( "% -#{maxlen_val}s" * val_count )

            puts sprintf(format, 'module', *updates.first[1].keys)

            updates.each do |name, hash|
                puts sprintf(format, name, *hash.values)
            end
        end

        desc 'fixture', 'Create puppetlabs_spec_helper compatible .fixtures.yml from puppetfile or metadata.json'
        method_option :stdout, :aliases => '-o'
        def fixture
            t = [nil, nil]
            %i{puppetfile metadata}.each do |m|
                if not options[m].nil?
                    t = [m, options[m]]
                end
            end

            Puppetfiler.fixture(*t, {}, options[:stdout])
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
