require 'json'
require 'puppetfiler/mod'
require 'semantic_puppet'

module Puppetfiler
    class Metadata
        attr :dependencies
        attr :path
        def initialize(target)
            @dependencies = {}

            parse target
        end

        def fixture(modifiers = {})
            Puppetfiler.fixture(@dependencies, {}, modifiers)
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
        def parse(target)
            json = JSON.load(target)

            if not json.has_key?('dependencies') or json['dependencies'].eql?([])
                STDERR.puts "No dependencies in file '#{@path}' found"
                return nil
            end

            json['dependencies'].each do |hash|
                @dependencies[hash['name']] = Puppetfiler::Mod.new(hash)
            end
        end
    end
end
