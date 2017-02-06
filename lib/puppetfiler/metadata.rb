require 'json'
require 'puppetfiler/mod'
require 'semantic_puppet'

module Puppetfiler
    class Metadata
        class Dependency
            attr :name
            attr :version_requirement

            def initialize(name, version_requirement)
                @path = name
                @version_requirement = SemanticPuppet::VersionRange.parse(version_requirement)
            end

            def eql?(other)
                return true if @name.eql?(other.name) and @version_requirement.eql?(other.version_requirement)
            end

            def version
                return Puppetfiler::Mod.newest(@name)
            end
        end

        attr :dependencies
        attr :path
        def initialize(path = 'metadata.json')
            @path = path
            @dependencies = {}

            parse File.read(@path)
        end

        def fixture(modifiers = {})
            # TODO: Move fixture methdod out of puppetfile class to
            # parent class
            #
            # modules/repos should be pass-able values
            #
            # An invocation from the puppetfile class would look like
            #
            #   Puppetfiler.fixture(@modules, @repos, modifier)
            #
            # and from this class
            #
            #   Puppetfiler.fixture(@dependencies, {})
            #
            # However this requires that the way forge modules are
            # handles is changed a bit.
            # I think the best way would be to modify Puppetfiler::Mod
            # to fit the needs,
        end

        def eql?(other)
            @dependencies.eql?(other.dependencies)
        end

        private
        def parse(content)
            json = JSON.load(content)

            if not json.has_key?('dependencies') or json['dependencies'].eql?([])
                STDERR.puts "No dependencies in file '#{@path}' found"
                return nil
            end

            json['dependencies'].each do |hash|
                @dependencies[hash['name']] = Dependency.new(hash['name'], hash['version_requirement']).version
            end
        end
    end
end
