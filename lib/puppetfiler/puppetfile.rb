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
            # TODO add error handling if target doesn't exist
            self.instance_eval(File.read(@puppetfile))
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

        def fixture
            fixtures = {
                'forge_modules' => {},
                'repositories'  => {},
            }

            @modules.each do |name, version|
                fixtures['forge_modules'][name.split('/')[1]] = {
                    'repo' => name,
                    'ref'  => version,
                }
            end

            @repos.each do |name, hash|
                if hash.has_key?(:ref)
                    content = {
                        'repo' => hash[:uri],
                        'ref'  => hash[:ref],
                    }
                else
                    content = hash[:uri]
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
