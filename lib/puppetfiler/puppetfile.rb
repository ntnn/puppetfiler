require 'puppetfiler'

module Puppetfiler
    class Puppetfile
        attr :modules
        attr :repos
        attr :puppetfile

        def initialize(path = 'Puppetfile')
            @modules    = {}
            @repos      = {}
            @puppetfile = path

            self.evaluate
        end

        def evaluate
            if not File.exists?(@puppetfile)
                STDERR.puts "Puppetfile not found at path '#{@puppetfile}'"
                return nil
            end

            begin
                # TODO similar to Metadata, allow IO objects like File,
                # string or similar to be passed in instead of expecting
                # a path
                self.instance_eval(File.read(@puppetfile))
            rescue SyntaxError => error
                STDERR.puts "Puppetfile at path '#{@puppetfile}' is invalid:"
                STDERR.puts error
                return nil
            end
        end

        def updates
            require 'concurrent'

            updates = {}

            mods = @modules.map do |name, mod|
                Concurrent::Future.execute do
                    current = mod.version
                    newest = mod.latest

                    if not newest.eql?(current)
                        updates[name] = {
                            :current => current,
                            :newest  => newest,
                        }
                    end
                end
            end

            # A timeout of 300 seconds per job should be plenty
            # TODO configurable timeout
            mods.each { |f| f.wait_or_cancel(300) }

            return updates
        end

        def fixture(modifiers = {})
            Puppetfiler::Fixture.fixture(@modules, @repos, modifiers)
        end

        private

        def moduledir(*args)
        end

        def mod(name, *args)
            arg = args[0]

            if arg.is_a?(String)
                return if arg == 'latest'

                @modules[name] = Puppetfiler::Mod.new(:name => name, :version => arg)

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
