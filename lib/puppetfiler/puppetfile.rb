require 'puppetfiler/mod'

module Puppetfiler
    class Puppetfile
        attr :modules
        attr :repos
        attr :puppetfile
        attr :maxlen_name

        def initialize(path = 'Puppetfile')
            @modules    = {}
            @repos      = {}
            @puppetfile = path

            @maxlen_name = 0
            @maxlen_ver  = 0

            self.evaluate
        end

        def evaluate
            if not File.exists?(@puppetfile)
                STDERR.puts "Puppetfile not found at path '#{@puppetfile}'"
                return nil
            end

            begin
                self.instance_eval(File.read(@puppetfile))
            rescue SyntaxError => error
                STDERR.puts "Puppetfile at path '#{@puppetfile}' is invalid:"
                STDERR.puts error
                return nil
            end
        end

        def maxlen_ver
            [@maxlen_ver, 'current'.length].max
        end

        def updates
            updates = {}

            @modules.each do |name, version|
                current = SemanticPuppet::Version.parse(version)
                newest = Puppetfiler::Mod.newest(name)

                if not newest.eql?(current)
                    updates[name] = {
                        :current => current,
                        :newest  => newest,
                    }
                end
            end

            return updates
        end

        def fixture(modifiers = {})
            fixtures = {
                'forge_modules' => {},
                'repositories'  => {},
            }

            fixtures.each do |k, v|
                modifiers[k] = {} if not modifiers.has_key?(k)
            end

            @modules.each do |name, version|
                short = name.split('/')[1]
                value = {
                    'repo' => name,
                    'ref'  => version,
                }

                modifiers['forge_modules'].each do |modifier, merger|
                    # TODO use x.match?(y) on ruby 2.4
                    value.merge!(merger) if name =~ /#{modifier}/
                end

                fixtures['forge_modules'][short] = value
            end

            @repos.each do |name, hash|
                if hash.has_key?(:ref)
                    content = {
                        'repo' => hash[:uri],
                        'ref'  => hash[:ref],
                    }

                    modifiers['repositories'].each do |modifier, merger|
                        content.merge!(merger) if name =~ /#{modifier}/
                    end
                else
                    content = hash[:uri]

                    modifiers['repositories'].each do |modifier, merger|
                        if name =~ /#{modifier}/
                            if merger.is_a?(String)
                                content = merger
                            else
                                content = {
                                    'repo' => hash[:uri],
                                }

                                content.merge!(merger)
                            end
                        end
                    end
                end

                fixtures['repositories'][name] = content
            end

            fixtures
        end

        private

        def moduledir(*args)
        end

        def mod(name, *args)
            arg = args[0]

            if arg.is_a?(String)
                return if arg == 'latest'
                @modules[name] = arg
                @maxlen_name = name.length if name.length > @maxlen_name
                @maxlen_ver  = arg.length if arg.length > @maxlen_ver
            else args.is_a?(Hash)

                @repos[name] = {}

                # TODO support local(?)
                %i{git svn}.each do |vcs|
                    @repos[name][:uri] = arg[vcs] if arg.keys.member?(vcs)
                end

                # TODO support fallbacks, e.g. using the rugged provider
                # which is also used by puppetlabs_spec_helper
                %i{fallback branch tag commit}.each do |ref|
                    @repos[name][:ref] = arg[ref] if arg.keys.member?(ref)
                end

            end
        end

    end
end
